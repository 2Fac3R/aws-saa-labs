provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# --- S3 Bucket for Testing ---
resource "aws_s3_bucket" "data_bucket" {
  bucket        = "aws-saa-labs-data-${local.account_id}"
  force_destroy = true
}

# --- S3 Object Deployment (Architect Way) ---
resource "aws_s3_object" "validation_script" {
  bucket = aws_s3_bucket.data_bucket.id
  key    = "scripts/s3_check.py"
  source = "../../apps/validation/s3_check.py"
  etag   = filemd5("../../apps/validation/s3_check.py")
}

# --- IAM Role for EC2 ---
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# --- IAM Policy for S3 Access ---
resource "aws_iam_policy" "s3_read_only" {
  name        = "S3ReadOnlyAccessToLabBucket"
  description = "Allows read access to the lab S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Effect   = "Allow"
        Resource = aws_s3_bucket.data_bucket.arn
      },
      {
        Action = [
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.data_bucket.arn}/*"
      }
    ]
  })
}

# --- Attach Policies to Role ---
resource "aws_iam_role_policy_attachment" "attach_s3_read" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.s3_read_only.arn
}

resource "aws_iam_role_policy_attachment" "attach_ssm_core" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# --- IAM Instance Profile ---
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-access-profile"
  role = aws_iam_role.ec2_s3_access_role.name
}

# --- EC2 Instance ---
# Using Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "lab_ec2" {
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "Lab-1-IAM-EC2"
  }

  user_data = <<-EOD
              #!/bin/bash
              # Update and install dependencies
              dnf update -y
              dnf install -y python3-pip aws-cli
              
              # Install Boto3
              pip3 install boto3
              
              # Create directory and FETCH validation script from S3
              mkdir -p /home/ec2-user/scripts
              aws s3 cp s3://${aws_s3_bucket.data_bucket.id}/scripts/s3_check.py /home/ec2-user/scripts/s3_check.py
              chown ec2-user:ec2-user /home/ec2-user/scripts/s3_check.py
              EOD
}
