from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import boto3
import os
import logging
from typing import Optional, Dict, Any

# Configure Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("api")

app = FastAPI(
    title="AWS SAA Lab 11 - SQS Messaging API",
    description="FastAPI application that dispatches messages to SQS standard and FIFO queues."
)

# Load SQS Queue URLs from environment variables
STANDARD_QUEUE_URL = os.getenv("STANDARD_QUEUE_URL")
FIFO_QUEUE_URL = os.getenv("FIFO_QUEUE_URL")
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")

# Initialize boto3 SQS client
sqs_client = boto3.client("sqs", region_name=AWS_REGION)

class StandardMessagePayload(BaseModel):
    message: str
    attributes: Optional[Dict[str, str]] = None

class FifoMessagePayload(BaseModel):
    message: str
    message_group_id: str
    message_deduplication_id: Optional[str] = None # Optional because we enabled content-based deduplication
    attributes: Optional[Dict[str, str]] = None

@app.get("/")
def read_root():
    return {
        "status": "online",
        "service": "SQS Messaging API",
        "configuration": {
            "standard_queue_configured": STANDARD_QUEUE_URL is not None,
            "fifo_queue_configured": FIFO_QUEUE_URL is not None,
            "aws_region": AWS_REGION
        }
    }

@app.post("/send-standard")
def send_standard_message(payload: StandardMessagePayload):
    if not STANDARD_QUEUE_URL:
        raise HTTPException(
            status_code=500,
            detail="STANDARD_QUEUE_URL environment variable is not configured."
        )

    try:
        # Construct message attributes if provided
        message_attributes = {}
        if payload.attributes:
            for k, v in payload.attributes.items():
                message_attributes[k] = {
                    'DataType': 'String',
                    'StringValue': v
                }

        # Send message to SQS
        response = sqs_client.send_message(
            QueueUrl=STANDARD_QUEUE_URL,
            MessageBody=payload.message,
            MessageAttributes=message_attributes
        )

        logger.info(f"Sent message to Standard Queue: MessageId={response.get('MessageId')}")
        return {
            "status": "success",
            "message_id": response.get("MessageId"),
            "md5_of_message_body": response.get("MD5OfMessageBody")
        }

    except Exception as e:
        logger.error(f"Failed to send message to Standard Queue: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/send-fifo")
def send_fifo_message(payload: FifoMessagePayload):
    if not FIFO_QUEUE_URL:
        raise HTTPException(
            status_code=500,
            detail="FIFO_QUEUE_URL environment variable is not configured."
        )

    try:
        # Construct message attributes if provided
        message_attributes = {}
        if payload.attributes:
            for k, v in payload.attributes.items():
                message_attributes[k] = {
                    'DataType': 'String',
                    'StringValue': v
                }

        # Setup parameters
        params = {
            "QueueUrl": FIFO_QUEUE_URL,
            "MessageBody": payload.message,
            "MessageGroupId": payload.message_group_id,
            "MessageAttributes": message_attributes
        }

        # Content-based deduplication is active, but allow overriding deduplication ID if passed
        if payload.message_deduplication_id:
            params["MessageDeduplicationId"] = payload.message_deduplication_id

        # Send message to SQS
        response = sqs_client.send_message(**params)

        logger.info(f"Sent message to FIFO Queue: MessageId={response.get('MessageId')}, SequenceNumber={response.get('SequenceNumber')}")
        return {
            "status": "success",
            "message_id": response.get("MessageId"),
            "sequence_number": response.get("SequenceNumber"),
            "md5_of_message_body": response.get("MD5OfMessageBody")
        }

    except Exception as e:
        logger.error(f"Failed to send message to FIFO Queue: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
