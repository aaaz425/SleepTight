# app/utils/inference.py
import torch
import numpy as np
from pathlib import Path
import tempfile

from .audio import opus_to_wav, load_wav
from tensorflow_hub import KerasLayer
from torch import nn
from ..config import SR, WINDOW_LENGTH, HOP_LENGTH, THRESHOLD, MODEL_PATH

# 1) SED 모델 래퍼
class YamNetTFWrapper:
    def __init__(self, model_path="https://tfhub.dev/google/yamnet/1"):
        self.layer = KerasLayer(model_path, trainable=False)
    def extract_embeddings(self, waveform: np.ndarray) -> np.ndarray:
        """
        1D float32 waveform → (time_frames, 1024) 임베딩
        """
        _, embeddings, _ = self.layer(waveform)
        return embeddings.numpy()

class YamNetClassifier(nn.Module):
    def __init__(self, num_classes=4, embedding_dim=1024):
        super().__init__()
        self.classifier = nn.Sequential(
            nn.Linear(embedding_dim, 512),
            nn.ReLU(inplace=True),
            nn.Dropout(0.3),
            nn.Linear(512, 256),
            nn.ReLU(inplace=True),
            nn.Dropout(0.3),
            nn.Linear(256, num_classes)
        )
    def forward(self, x):
        return self.classifier(x)

# 2) 전역 모델 로드
_tf_wrapper = YamNetTFWrapper()
_device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
_pt_model = YamNetClassifier(num_classes=4).to(_device)
_pt_model.load_state_dict(torch.load(MODEL_PATH, map_location=_device))
_pt_model.eval()

_CLASSES = ["snore", "breathe", "somniloquy", "cough"]

def detect_events(opus_path: str, duration: float) -> list[dict]:
    """
    1) Opus → WAV
    2) load_wav으로 전처리된 waveform 로드
    3) 슬라이딩 윈도(윈도우 길이, 홉 길이 from config)별 추론
    4) softmax 확률 ≥ THRESHOLD인 세그먼트만 결과에 추가
    5) [{start, end, label, prob, all_probs}, ...] 반환
    """
    opus_path = Path(opus_path)
    # 임시 WAV 파일
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
        wav_path = Path(tmp.name)

    # 1) Opus → WAV
    opus_to_wav(opus_path, wav_path)

    # 2) 정규화/트리밍 + 로드
    waveform = load_wav(wav_path)

    # 3) 윈도우 파라미터
    win_samples = int(WINDOW_LENGTH * SR)
    hop_samples = int(HOP_LENGTH * SR)
    if hop_samples <= 0:
        hop_samples = win_samples

    results = []
    for start in range(0, len(waveform) - win_samples + 1, hop_samples):
        end = start + win_samples
        segment = waveform[start:end]

        # 4) 임베딩 → 분류
        emb = _tf_wrapper.extract_embeddings(segment)
        feat = emb.mean(axis=0, keepdims=True)  # (1,1024)
        with torch.no_grad():
            logits = _pt_model(torch.from_numpy(feat).to(_device))
            probs = torch.softmax(logits, 1)[0].cpu().numpy()  # (4,)

        idx = int(probs.argmax())
        p = float(probs[idx])
        if p >= THRESHOLD:
            results.append({
                "start": start / SR,
                "end":   end   / SR,
                "label": _CLASSES[idx],
                "prob":  p,
                "all_probs": {cls: float(probs[i]) for i, cls in enumerate(_CLASSES)}
            })

    return results
