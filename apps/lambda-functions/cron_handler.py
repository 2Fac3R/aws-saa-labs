import json
import time

def lambda_handler(event, context):
    """
    Simple handler for scheduled serverless jobs and custom event routing
    triggered by Amazon EventBridge.
    """
    print("=== EventBridge Lambda Triggered ===")
    print(f"Time: {time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime())}")
    print(f"Received Event: {json.dumps(event, indent=2)}")
    
    # Check if the event is a scheduled/cron event or custom event
    source = event.get("source", "unknown")
    detail_type = event.get("detail-type", "unknown")
    
    print(f"Event Source: {source}")
    print(f"Event Detail-Type: {detail_type}")
    
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Event logged successfully",
            "source": source,
            "detailType": detail_type
        })
    }
