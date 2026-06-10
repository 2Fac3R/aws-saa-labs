import boto3
import os
import time
import sys
import argparse
import logging
from botocore.exceptions import ClientError

# Configure Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger("worker")

def run_worker(queue_url: str, aws_region: str, simulate_failure: bool, poll_limit: int = None):
    logger.info(f"Starting SQS Worker...")
    logger.info(f"Target Queue URL: {queue_url}")
    logger.info(f"Region:           {aws_region}")
    logger.info(f"Failure Mode:     {simulate_failure} (If True, messages won't be deleted and will flow to DLQ)")

    sqs_client = boto3.client("sqs", region_name=aws_region)
    poll_count = 0

    try:
        while True:
            if poll_limit is not None and poll_count >= poll_limit:
                logger.info(f"Poll limit of {poll_limit} reached. Exiting.")
                break

            logger.info("Polling for messages (long polling enabled, wait 10s)...")
            response = sqs_client.receive_message(
                QueueUrl=queue_url,
                MaxNumberOfMessages=1,
                WaitTimeSeconds=10, # SAA Concept: Long polling (reduces cost & empty responses)
                MessageAttributeNames=['All']
            )

            poll_count += 1
            messages = response.get("Messages", [])

            if not messages:
                logger.info("No messages received.")
                continue

            for msg in messages:
                message_id = msg.get("MessageId")
                body = msg.get("Body")
                receipt_handle = msg.get("ReceiptHandle")

                logger.info(f"==========================================")
                logger.info(f"Received Message ID: {message_id}")
                logger.info(f"Body: {body}")

                if msg.get("MessageAttributes"):
                    logger.info(f"Attributes: {msg.get('MessageAttributes')}")

                # Simulate processing time
                logger.info("Processing message...")
                time.sleep(1.5)

                if simulate_failure:
                    # In simulate failure mode, we do NOT delete the message.
                    # This allows the visibility timeout to expire so the message returns to the queue.
                    # Once received 'maxReceiveCount' times, SQS moves it to the DLQ.
                    logger.warning("Simulating processing FAILURE! Message NOT deleted from queue.")
                    logger.info("It will remain invisible until the visibility timeout expires.")
                else:
                    # Success: Acknowledge processing by deleting message from the queue
                    logger.info("Processing success. Deleting message from SQS queue...")
                    sqs_client.delete_message(
                        QueueUrl=queue_url,
                        ReceiptHandle=receipt_handle
                    )
                    logger.info("✅ Message successfully deleted.")
                logger.info(f"==========================================")

    except KeyboardInterrupt:
        logger.info("Worker stopped by user (SIGINT). Exiting.")
    except ClientError as e:
        logger.error(f"AWS Client Error: {e}")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="AWS SAA SQS Background Worker")
    parser.add_argument("--queue-url", type=str, help="SQS Queue URL (defaults to QUEUE_URL env var)")
    parser.add_argument("--region", type=str, default="us-east-1", help="AWS Region (defaults to AWS_REGION env var or us-east-1)")
    parser.add_argument("--simulate-failure", action="store_true", help="Do not delete processed messages to test DLQ flow")
    parser.add_argument("--poll-limit", type=int, default=None, help="Number of poll attempts before exiting (useful for automated testing)")

    args = parser.parse_args()

    # Priority: argument > env variable
    q_url = args.queue_url or os.getenv("QUEUE_URL")
    region = args.region or os.getenv("AWS_REGION", "us-east-1")
    sim_fail = args.simulate_failure or (os.getenv("SIMULATE_FAILURE", "false").lower() == "true")

    if not q_url:
        logger.error("Error: SQS Queue URL is not provided. Set QUEUE_URL environment variable or pass --queue-url.")
        sys.exit(1)

    run_worker(
        queue_url=q_url,
        aws_region=region,
        simulate_failure=sim_fail,
        poll_limit=args.poll_limit
    )
