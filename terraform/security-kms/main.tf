provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# --- 1. KMS Customer Managed Key (CMK) ---
# SAA Topic: Encryption at Rest & Key Policies
resource "aws_kms_key" "lab_key" {
  description             = "KMS key for encrypting lab secrets"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  # SAA Exam Focus: Key Policy (The ONLY way to control access to a key)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow access for Key Administrators"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        }
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ]
        Resource = "*"
      }
    ]
  })

  tags = { Name = "lab-encryption-key" }
}

resource "aws_kms_alias" "lab_key_alias" {
  name          = "alias/lab-key"
  target_key_id = aws_kms_key.lab_key.key_id
}

# --- 2. AWS Secrets Manager with KMS Encryption ---
# SAA Topic: Envelope Encryption
resource "aws_secretsmanager_secret" "secure_app_secret" {
  name                    = "lab/app/secure-api-key"
  description             = "A secret encrypted with a Customer Managed Key"
  kms_key_id              = aws_kms_key.lab_key.arn
  recovery_window_in_days = 0 # Force immediate deletion for lab teardown
}

resource "aws_secretsmanager_secret_version" "secure_app_secret_v1" {
  secret_id = aws_secretsmanager_secret.secure_app_secret.id
  secret_string = jsonencode({
    api_key     = "super-secret-12345"
    environment = "production"
    note        = "Encrypted via CMK"
  })
}
