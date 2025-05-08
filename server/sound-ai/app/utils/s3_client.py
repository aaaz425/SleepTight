# app/utils/s3_client.py
import os
import boto3
from ..config import S3_BUCKET_NAME

s3 = boto3.client("s3")

def download_from_s3(s3_key: str, local_path: str):
    """
    S3 버킷에서 지정된 키(s3_key)를 로컬 파일(local_path)로 다운로드
    """
    s3.download_file(S3_BUCKET_NAME, s3_key, local_path)
