# app/utils/inference.py
import os
import json
import tempfile
from pathlib import Path
import numpy as np
import torch
import torch.nn as nn
import tensorflow_hub as hub
from torch.nn.utils.rnn import pack_padded_sequence
from tqdm import tqdm

from utils.audio import opus_to_wav, load_wav
from config import SR, WINDOW_LENGTH, HOP_LENGTH, THRESHOLD, MODEL_PATH

# --- 1. YAMNet TF 래퍼 ---
class YamNetTFWrapper:
    def __init__(self, url: str = "https://tfhub.dev/google/yamnet/1"):
        self.layer = hub.KerasLayer(url, trainable=False)

    def extract_embeddings(self, waveform: np.ndarray) -> np.ndarray:
        # waveform: 1D float32
        _, embeddings, _ = self.layer(waveform)
        return embeddings.numpy()[0]  # (time_frames, 1024)

# --- 2. LSTM 기반 분류기 ---
class YamNetLSTMClassifier(nn.Module):
    def __init__(self, num_classes: int = 4, embedding_dim: int = 1024,
                 hidden_size: int = 512, num_layers: int = 1, bidirectional: bool = True):
        super().__init__()
        self.lstm = nn.LSTM(
            input_size=embedding_dim,
            hidden_size=hidden_size,
            num_layers=num_layers,
            batch_first=True,
            bidirectional=bidirectional
        )
        lstm_out_dim = hidden_size * (2 if bidirectional else 1)
        self.classifier = nn.Sequential(
            nn.Linear(lstm_out_dim, 512),
            nn.ReLU(inplace=True),
            nn.Dropout(0.3),
            nn.Linear(512, 256),
            nn.ReLU(inplace=True),
            nn.Dropout(0.3),
            nn.Linear(256, num_classes)
        )

    def forward(self, x, lengths):
        packed = pack_padded_sequence(x, lengths.cpu(), batch_first=True, enforce_sorted=False)
        packed_out, (h_n, _) = self.lstm(packed)
        if self.lstm.bidirectional:
            h_fwd = h_n[-2]
            h_bwd = h_n[-1]
            h = torch.cat((h_fwd, h_bwd), dim=1)
        else:
            h = h_n[-1]
        return self.classifier(h)

# --- 3. 전역 모델 로드 ---
_device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
_tf_wrapper = YamNetTFWrapper()
_pt_model = YamNetLSTMClassifier(num_classes=len(_tf_wrapper.layer._func.__call__(  # 임시 입력으로 클래스 수 추출
    np.zeros((SR, ), dtype=np.float32)
))).to(_device)
_pt_model.load_state_dict(torch.load(MODEL_PATH, map_location=_device))
_pt_model.eval()

# 라벨 순서는 config나 학습 시 사용한 순서와 일치해야 합니다.
_CLASSES = ["snore", "cough", "breathe", "somniloquy"]


def detect_events(opus_path: str, duration: float) -> list[dict]:
    """
    1) Opus → WAV
    2) load_wav으로 로드
    3) 슬라이딩 윈도우별 LSTM 예측
    4) softmax ≥ THRESHOLD 결과 수집
    """
    opus_path = Path(opus_path)
    tmp = tempfile.NamedTemporaryFile(suffix=".wav", delete=False)
    wav_path = Path(tmp.name)
    tmp.close()

    try:
        # 1) Opus → WAV
        opus_to_wav(opus_path, wav_path)

        # 2) WAV 로드
        waveform = load_wav(wav_path)
        if waveform.size == 0:
            return []

        win_samples = int(WINDOW_LENGTH * SR)
        hop_samples = int(HOP_LENGTH * SR) or win_samples
        results = []

        # 3) 예측
        for start in range(0, len(waveform) - win_samples + 1, hop_samples):
            segment = waveform[start:start + win_samples]
            embeddings = _tf_wrapper.extract_embeddings(segment)
            # (time_frames, 1024)
            if embeddings.ndim == 1:
                embeddings = embeddings[np.newaxis, :]
            lengths = torch.tensor([embeddings.shape[0]], dtype=torch.long).to(_device)
            seq = torch.from_numpy(embeddings).float().unsqueeze(0).to(_device)

            with torch.no_grad():
                logits = _pt_model(seq, lengths)
                probs = torch.softmax(logits, dim=1)[0].cpu().numpy()

            idx = int(np.argmax(probs))
            p = float(probs[idx])
            if p >= THRESHOLD:
                results.append({
                    "start": round(start / SR, 3),
                    "end": round((start + win_samples) / SR, 3),
                    "label": _CLASSES[idx],
                    "prob": p,
                    "all_probs": {cls: float(probs[i]) for i, cls in enumerate(_CLASSES)}
                })
        return results

    finally:
        # 임시 파일 삭제
        for p in (wav_path, opus_path):
            try: Path(p).unlink()
            except: pass
