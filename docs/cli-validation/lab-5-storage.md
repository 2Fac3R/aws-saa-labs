# CLI Validation: Lab 5 - S3 & CloudFront

## 1. Verify S3 Advanced Settings
```bash
BUCKET_NAME=$(aws s3 ls | grep aws-saa-labs-assets | cut -d' ' -f3)

# Verify Versioning Status
aws s3api get-bucket-versioning --bucket $BUCKET_NAME --query "Status"

# Verify Lifecycle Rules
aws s3api get-bucket-lifecycle-configuration --bucket $BUCKET_NAME
```

## 2. Verify CloudFront Distribution
```bash
# List distributions and their origins
aws cloudfront list-distributions --query "DistributionList.Items[*].{ID:Id, Domain:DomainName, Origin:Origins.Items[0].DomainName}"
```

## 3. Verify Origin Access Control (OAC)
```bash
# Check if the Bucket Policy allows CloudFront Service Principal
aws s3api get-bucket-policy --bucket $BUCKET_NAME --query "Policy" --output text | jq .
```

## 4. Test Edge Connectivity
```bash
CF_DOMAIN=$(aws cloudfront list-distributions --query "DistributionList.Items[?contains(Comment, 'lab-cdn')].DomainName" --output text)

# Upload a test file to S3
echo "Hello from CloudFront Edge" > index.html
aws s3 cp index.html s3://$BUCKET_NAME/index.html

# Attempt to fetch via CloudFront (Should succeed)
curl -i "https://$CF_DOMAIN/index.html"

# Attempt to fetch directly from S3 (Should be Denied)
S3_URL="https://$BUCKET_NAME.s3.amazonaws.com/index.html"
curl -i "$S3_URL"
```
