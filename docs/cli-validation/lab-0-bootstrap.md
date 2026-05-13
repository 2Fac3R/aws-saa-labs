# CLI Validation: Lab 0 - Terraform Bootstrap

## 1. Verify S3 State Bucket
Confirm the bucket exists and has the correct security settings.

```bash
BUCKET_NAME="aws-saa-labs-tfstate-444386042261-us-east-1"

# Check if bucket exists
aws s3api head-bucket --bucket $BUCKET_NAME

# Verify Versioning is Enabled
aws s3api get-bucket-versioning --bucket $BUCKET_NAME --query "Status"

# Verify Encryption (SSE-S3)
aws s3api get-bucket-encryption --bucket $BUCKET_NAME --query "ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm"

# Verify Public Access Block (Should all be true)
aws s3api get-public-access-block --bucket $BUCKET_NAME --query "PublicAccessBlockConfiguration"
```

## 2. Verify DynamoDB Lock Table
```bash
TABLE_NAME="aws-saa-labs-tfstate-locks"

# Check table status and Partition Key
aws dynamodb describe-table --table-name $TABLE_NAME --query "Table.{Status:TableStatus, Key:AttributeDefinitions[0].AttributeName}"
```
