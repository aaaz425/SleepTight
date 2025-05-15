# app/utils/inference.py
import torch
import numpy as np
from pathlib import Path
import tempfile
import logging

from utils.audio import opus_to_wav, load_wav
import tensorflow as tf
from tensorflow_hub import KerasLayer
from torch import nn
from pydub import AudioSegment
from pydub.silence import detect_nonsilent
from config import SR, WINDOW_LENGTH, HOP_LENGTH, THRESHOLD, MODEL_PATH, SR, TARGET_AMPLITUDE_DBFS, MIN_SILENCE_LEN_MS, SILENCE_THRESH_OFFSET_DB


logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s [%(levelname)s] %(message)s")

# GPU 사용 가능 여부 로깅
logging.info(f"Torch CUDA available: {torch.cuda.is_available()}, "
             f"Torch CUDA device count: {torch.cuda.device_count()}")
tf_gpus = tf.config.list_physical_devices('GPU')
logging.info(f"TensorFlow GPU devices: {tf_gpus if tf_gpus else 'None'}")

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
    # 1) 임시 WAV 파일 생성
    tmp_wav = tempfile.NamedTemporaryFile(suffix=".wav", delete=False)
    wav_path = Path(tmp_wav.name)
    tmp_wav.close()

    try:
        # 2) Opus → WAV 변환
        opus_to_wav(opus_path, wav_path)

        # 3) 전체 파일 전처리된 waveform 로드
        waveform = load_wav(wav_path)

        # 4) 윈도/홉 샘플 계산
        win_samples = int(WINDOW_LENGTH * SR)
        hop_samples = int(HOP_LENGTH * SR) or win_samples

        results = []
        # 5) 슬라이딩 윈도우별 처리
        max_int16 = float(1 << 15)
        for start in range(0, len(waveform) - win_samples + 1, hop_samples):
            end = start + win_samples
            raw_seg = waveform[start:end]  # float32[-1~1]

            # a) numpy → int16 PCM → AudioSegment
            int16_seg = (raw_seg * max_int16).astype(np.int16)
            seg_audio = AudioSegment(
                data=int16_seg.tobytes(),
                sample_width=2,
                frame_rate=SR,
                channels=1
            )

            # b) 세그먼트 볼륨 정규화
            change_db = TARGET_AMPLITUDE_DBFS - seg_audio.dBFS
            seg_audio = seg_audio.apply_gain(change_db)

            # c) 세그먼트 무음 앞뒤 트리밍
            silence_thresh = seg_audio.dBFS - SILENCE_THRESH_OFFSET_DB
            nons = detect_nonsilent(
                seg_audio,
                min_silence_len=MIN_SILENCE_LEN_MS,
                silence_thresh=silence_thresh
            )
            if nons:
                s_ms, e_ms = nons[0][0], nons[-1][1]
                seg_audio = seg_audio[s_ms:e_ms]

            # d) AudioSegment → numpy float32
            seg_samples = np.array(seg_audio.get_array_of_samples(), dtype=np.float32)
            seg_samples /= max_int16

            # e) 임베딩 추출 & 분류
            emb = _tf_wrapper.extract_embeddings(seg_samples)
            feat = emb.mean(axis=0, keepdims=True)
            with torch.no_grad():
                logits = _pt_model(torch.from_numpy(feat).to(_device))
                probs = torch.softmax(logits, 1)[0].cpu().numpy()

            idx = int(probs.argmax())
            p = float(probs[idx])
            if p >= THRESHOLD:
                results.append({
                    "start":     start / SR,
                    "end":       end   / SR,
                    "label":     _CLASSES[idx],
                    "prob":      p,
                    "all_probs": {cls: float(probs[i]) for i, cls in enumerate(_CLASSES)}
                })

        return results

    finally:
        # 6) 임시 WAV 및 OPUS 파일 삭제 (로컬에 생성된 것만)
        for p in (wav_path, opus_path):
            try:
                Path(p).unlink()
            except Exception:
                pass
