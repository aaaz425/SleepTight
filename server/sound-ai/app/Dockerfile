# 1) RunPod PyTorch CUDA 베이스 이미지
FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

# 2) 시스템 의존성 및 ffmpeg 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ffmpeg \
      libcudnn8 \
      libcudnn8-dev && \
    rm -rf /var/lib/apt/lists/*

# 3) 작업 디렉터리 설정
WORKDIR /app
COPY . /app

# 4) Python 의존성 설치
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir \
      torch==2.7.0+cu118 \
      torchvision==0.22.0+cu118 \
      torchaudio==2.7.0+cu118 \
      --index-url https://download.pytorch.org/whl/cu118

RUN pip install --no-cache-dir tensorflow[and-cuda]

# 4.1) CUDA 라이브러리 검색 경로 설정
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}

# 5) 애플리케이션 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload", "--workers", "1"]
