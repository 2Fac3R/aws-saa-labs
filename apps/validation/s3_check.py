import boto3
from botocore.exceptions import ClientError

def validate_s3_access(bucket_name):
    s3 = boto3.client('s3')
    print(f"--- Validating access to bucket: {bucket_name} ---")
    
    try:
        # 1. Test Listing
        response = s3.list_objects_v2(Bucket=bucket_name)
        print("✅ Successfully listed bucket objects.")
        
        # 2. Test fetching bucket location (requires specific permission)
        location = s3.get_bucket_location(Bucket=bucket_name)
        print(f"✅ Bucket region: {location['LocationConstraint']}")
        
    except ClientError as e:
        print(f"❌ Access denied or error occurred: {e}")

if __name__ == "__main__":
    # In a real scenario, we'd pass this via env var or argument
    import sys
    if len(sys.argv) > 1:
        validate_s3_access(sys.argv[1])
    else:
        print("Please provide the bucket name as an argument.")
