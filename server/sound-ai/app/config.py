import os
from pathlib import Path


# 이 파일(config.py) 기준으로 한 단계 위로 올라간 src 루트 경로
BASE_DIR = Path(__file__).resolve().parent  

# RabbitMQ 설정
RABBITMQ_URL        = os.getenv("RABBITMQ_URL")              # ex: amqp://user:pass@host:5672/
QUEUE_NAME          = os.getenv("QUEUE_NAME", "")
ROUTING_KEY         = os.getenv("ROUTING_KEY", "")

RESULT_QUEUE_NAME   = os.getenv("RESULT_QUEUE_NAME", "")
RESULT_EXCHANGE     = os.getenv("RESULT_EXCHANGE", "")       # 기본 익스체인지
RESULT_ROUTING_KEY  = os.getenv("RESULT_ROUTING_KEY", "")

# Model path
MODEL_PATH          = os.getenv("MODEL_PATH", BASE_DIR / "model" / "model.pth")

# AWS S3 settings
S3_BUCKET_NAME      = os.getenv("S3_BUCKET_NAME")  # ex: "my-audio-bucket"
S3_BUCKET_REGION    = os.getenv("S3_BUCKET_REGION")

# Audio processing constants
SR = 16_000  # YamNet이 기대하는 샘플레이트
TARGET_AMPLITUDE_DBFS = -20.0      # 목표 데시벨값 (dBFS)
MIN_SILENCE_LEN_MS = 500           # 최소 무음 길이 (ms)
SILENCE_THRESH_OFFSET_DB = 16      # 무음 임계치 오프셋 (dB)

# Inference settings
WINDOW_LENGTH = 2.0  # 슬라이딩 윈도 길이 (초)
HOP_LENGTH = 0.0     # 홉 길이 (초), 0.0 이면 non-overlap
THRESHOLD = 0.5      # softmax 확률 최소 임계값
