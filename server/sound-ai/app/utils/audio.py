# app/utils/audio.py
import numpy as np
import subprocess
from pathlib import Path
from pydub import AudioSegment
from config import SR, TARGET_AMPLITUDE_DBFS


def opus_to_wav(opus_path: Path, wav_path: Path):
    """
    Opus 파일을 FFmpeg로 WAV(16kHz, 모노)로 변환
    """
    cmd = [
        "ffmpeg", "-y",
        "-i", str(opus_path),
        "-ar", str(SR),
        "-ac", "1",
        str(wav_path)
    ]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def load_wav(wav_path: Path) -> np.ndarray:
    """
    1) pydub으로 로드 (any 포맷 지원)
    2) 볼륨 정규화
    3) 16kHz 모노 → float32 PCM(-1~1) numpy array 반환
    """
    audio = AudioSegment.from_file(str(wav_path))
    audio = audio.set_channels(1).set_frame_rate(SR)

    # 볼륨 정규화
    change_db = TARGET_AMPLITUDE_DBFS - audio.dBFS
    audio = audio.apply_gain(change_db)

    samples = np.array(audio.get_array_of_samples(), dtype=np.float32)
    max_val = float(1 << (audio.sample_width * 8 - 1))
    samples /= max_val
    return samples
