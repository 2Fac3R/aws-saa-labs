# Lab 15: CloudTrail & Athena (Auditing & Log Analysis)

## Objective
Establish a centralized auditing system to track all API activity across the AWS account and use Amazon Athena to perform ad-hoc SQL analysis on the generated logs.

## Architecture
![Lab 15 Architecture](../diagrams/lab-15-auditing-athena.svg)

## Key Concepts

### 1. AWS CloudTrail
CloudTrail is a service that enables governance, compliance, operational auditing, and risk auditing of your AWS account.
- **Management Events:** Provide visibility into management operations that are performed on resources in your AWS account (e.g., creating a VPC, launching an EC2).
- **Data Events:** (Optional) Provide visibility into the resource operations performed on or within a resource (e.g., S3 object-level activity). These are high-volume and incur extra costs.
- **Storage:** Logs are stored as JSON files in an S3 bucket.

### 2. Amazon Athena
Athena is an interactive query service that makes it easy to analyze data in Amazon S3 using standard SQL.
- **Serverless:** There is no infrastructure to manage, and you pay only for the queries that you run.
- **Data Catalog:** Athena uses a schema-on-read approach, typically defined via the AWS Glue Data Catalog.

### 3. S3 Bucket Policies for CloudTrail
CloudTrail requires specific permissions to write logs to your S3 bucket. The bucket policy must allow `cloudtrail.amazonaws.com` to perform `s3:GetBucketAcl` and `s3:PutObject`.

## Implementation Details
- **Trail Name:** `lab-management-trail`
- **Logging:** Enabled for Management Events in the current region.
- **Athena Database:** `lab_cloudtrail_db`
- **Workgroup:** `lab-auditing-workgroup`

## SAA Exam Takeaways
- **CloudTrail is Global by default** (can log all regions), but can be scoped to a single region.
- **Log Integrity Validation:** CloudTrail can use digital signatures to ensure that logs haven't been modified after delivery.
- **Athena is the primary tool for querying logs** (CloudTrail, VPC Flow Logs, ALB Access Logs) stored in S3.
- **KMS Integration:** CloudTrail logs can be encrypted using KMS Customer Managed Keys (CMKs) for extra security.
