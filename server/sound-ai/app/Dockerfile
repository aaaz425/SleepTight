# RunPod GPU 환경에 최적화된 PyTorch CUDA 베이스 이미지 사용
FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

# 작업 디렉터리 설정
WORKDIR /app

# Python 의존성 복사 및 설치
COPY . /app
RUN pip install --no-cache-dir -r requirements.txt

# CUDA 지원 torch/torchvision/torchaudio 설치
RUN pip install --no-cache-dir \
    torch==2.7.0+cu118 \
    torchvision==0.22.0+cu118 \
    torchaudio==2.7.0+cu118 \
    --index-url https://download.pytorch.org/whl/cu118

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
