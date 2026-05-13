# Lab 1: IAM - EC2 Accesses S3 without Credentials

## Objective
Demonstrate how to provide secure, credential-less access to AWS services from an EC2 instance using IAM Roles and Instance Profiles.

## Architecture
![Lab 1 Architecture](../diagrams/lab-1-iam.svg)

## Key Concepts
### 1. Trust Relationship (AssumeRolePolicy)
Defines which principal (service or account) can assume the role. In this lab, `ec2.amazonaws.com` is the trusted service.

### 2. Instance Profile
A container for an IAM role that can be used to pass role information to an EC2 instance. It acts as a bridge between IAM and EC2.

### 3. Instance Metadata Service (IMDS)
The EC2 instance uses IMDS (v2 by default on AL2023) to retrieve temporary security credentials. The AWS SDK (boto3) automatically handles this lookup.

### 4. Least Privilege
The IAM policy was scoped specifically to the test bucket rather than using `AmazonS3ReadOnlyAccess`, following the principle of least privilege.

## Validation Results
- **Connectivity:** Successful via SSM Session Manager (no SSH keys or inbound Port 22 required).
- **Listing Bucket:** Verified `s3:ListBucket` permission.
- **Location Check:** Verified `s3:GetBucketLocation`. Note that `us-east-1` returns `None`.

## SAA Exam Takeaways
- Use IAM Roles instead of Access Keys for applications running on AWS.
- Roles provide temporary credentials that rotate automatically.
- SSM Session Manager is the preferred secure way to access EC2 instances.
