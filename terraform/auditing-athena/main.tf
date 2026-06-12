provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# --- 1. S3 Bucket for CloudTrail Logs ---
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "aws-saa-labs-cloudtrail-${local.account_id}"
  force_destroy = true
}

# SAA Topic: Bucket Policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${local.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# --- 2. AWS CloudTrail ---
resource "aws_cloudtrail" "main" {
  name                          = "lab-management-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = false # For lab cost optimization
  enable_logging                = true

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

# --- 3. Amazon Athena ---

# S3 Bucket for Athena Query Results
resource "aws_s3_bucket" "athena_results" {
  bucket        = "aws-saa-labs-athena-results-${local.account_id}"
  force_destroy = true
}

resource "aws_athena_workgroup" "main" {
  name = "lab-auditing-workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/"
    }
  }
}

resource "aws_athena_database" "cloudtrail" {
  name   = "lab_cloudtrail_db"
  bucket = aws_s3_bucket.athena_results.bucket
}

