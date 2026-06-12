# CLI Validation: Lab 15 - CloudTrail & Athena

## 1. Verify CloudTrail Status
```bash
# Check if the trail is logging
aws cloudtrail get-trail-status --name "lab-management-trail" --query "{Logging:IsLogging, Latest:LatestDeliveryTime}"
```

## 2. Verify S3 Log Storage
```bash
BUCKET_NAME=$(aws cloudtrail describe-trails --trail-name-list "lab-management-trail" --query "trailList[0].S3BucketName" --output text)

# List some log files (Note: It can take 5-15 mins for the first logs to appear)
aws s3 ls "s3://$BUCKET_NAME/AWSLogs/" --recursive | head -n 10
```

## 3. Verify Athena Workgroup
```bash
# Check if the auditing workgroup exists
aws athena get-work-group --work-group "lab-auditing-workgroup" --query "WorkGroup.State"
```

## 4. Run an Athena Query (Conceptual)
To query CloudTrail logs in Athena, you first need to create a table. You can do this via the AWS Console or using the following CLI pattern:

```bash
# 1. Create the table (Standard CloudTrail schema)
# (Complex SQL omitted for brevity, but available in AWS Documentation)

# 2. Run a query (Example: Find who launched an EC2 instance)
QUERY="SELECT useridentity.arn, eventname, eventtime FROM cloudtrail_logs WHERE eventname = 'RunInstances' LIMIT 10"

aws athena start-query-execution \
    --query-string "$QUERY" \
    --workgroup "lab-auditing-workgroup" \
    --query-execution-context Database=lab_cloudtrail_db
```
