# app/consumer.py
import json
import logging
import pika
from datetime import datetime

from .config import (
    RABBITMQ_URL,
    QUEUE_NAME,
    ROUTING_KEY,
    RESULT_QUEUE_NAME,
    RESULT_EXCHANGE,
    RESULT_ROUTING_KEY,
)
from .utils.s3_client import download_from_s3
from .utils.inference import detect_events

logging.basicConfig(level=logging.INFO)
_conn    = pika.BlockingConnection(pika.URLParameters(RABBITMQ_URL))
_channel = _conn.channel()

# 0) 익스체인지 선언 (direct 타입)
_channel.exchange_declare(
    exchange=RESULT_EXCHANGE,
    exchange_type="direct",
    durable=True
)

# 1) 메타큐(consume) 선언 & 바인딩
_channel.queue_declare(queue=QUEUE_NAME, durable=True)
_channel.queue_bind(
    queue=QUEUE_NAME,
    exchange=RESULT_EXCHANGE,   # 직접 선언한 익스체인지 사용
    routing_key=ROUTING_KEY     # config의 ROUTING_KEY
)

# 2) 결과큐(publish) 선언 & 바인딩
_channel.queue_declare(queue=RESULT_QUEUE_NAME, durable=True)
_channel.queue_bind(
    queue=RESULT_QUEUE_NAME,
    exchange=RESULT_EXCHANGE,       # 동일한 익스체인지 사용
    routing_key=RESULT_ROUTING_KEY  # config의 RESULT_ROUTING_KEY
)

def _on_message(ch, method, props, body):
    try:
        meta       = json.loads(body)
        segment_id = meta["segmentId"]
        s3_key     = meta["s3Key"]
        duration   = float(meta["duration"])

        # S3에서 opus 다운로드
        # local opus는 서버의 local에 저장되는 opus 경로
        local_opus = f"/tmp/{segment_id}.opus"
        download_from_s3(s3_key, local_opus)

        # 이벤트 검출
        events = detect_events(local_opus, duration)

        # 결과 메타데이터 생성
        result = {
            "segmentId":  segment_id,
            "events":     events,
            "inferenceTs": datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ"),
        }
        _channel.basic_publish(
            exchange=RESULT_EXCHANGE,
            routing_key=RESULT_ROUTING_KEY,
            body=json.dumps(result),
            properties=pika.BasicProperties(
                content_type="application/json",
                delivery_mode=2,  # 영구 메시지
            )
        )

        logging.info(f"[{segment_id}] processed → events: {events}")
        ch.basic_ack(delivery_tag=method.delivery_tag)

    except Exception:
        logging.exception("Failed to process message")
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)

def start_consumer():
    logging.info("RabbitMQ consumer started, waiting for messages…")
    _channel.basic_qos(prefetch_count=1)
    _channel.basic_consume(
        queue=QUEUE_NAME,
        on_message_callback=_on_message
    )
    _channel.start_consuming()
