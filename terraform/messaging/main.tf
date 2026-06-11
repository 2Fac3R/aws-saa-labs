provider "aws" {
  region = var.aws_region
}

# ==========================================
# 1. Standard Queue & DLQ Setup
# ==========================================

# Standard Dead Letter Queue
resource "aws_sqs_queue" "standard_dlq" {
  name                      = "lab-standard-dlq"
  message_retention_seconds = 1209600 # 14 days (maximum retention for DLQs)

  tags = {
    Name        = "lab-standard-dlq"
    Environment = "dev"
  }
}

# Standard Primary Queue
resource "aws_sqs_queue" "standard_queue" {
  name                       = "lab-standard-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600 # 4 days
  delay_seconds              = 0
  max_message_size           = 262144 # 256 KB
  receive_wait_time_seconds  = 10     # Enable long polling (max 20)

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.standard_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "lab-standard-queue"
    Environment = "dev"
  }
}

# ==========================================
# 2. FIFO Queue & DLQ Setup
# ==========================================

# FIFO Dead Letter Queue
# Note: FIFO queues must end with the '.fifo' suffix
resource "aws_sqs_queue" "fifo_dlq" {
  name                        = "lab-fifo-dlq.fifo"
  fifo_queue                  = true
  message_retention_seconds   = 1209600 # 14 days
  content_based_deduplication = false   # Not strictly required on DLQ, but good practice

  tags = {
    Name        = "lab-fifo-dlq.fifo"
    Environment = "dev"
  }
}

# FIFO Primary Queue
# Note: FIFO queues must end with the '.fifo' suffix
resource "aws_sqs_queue" "fifo_queue" {
  name                        = "lab-fifo-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true # Automatically generate MessageDeduplicationId based on SHA-256 hash of body
  visibility_timeout_seconds  = 30
  message_retention_seconds   = 345600 # 4 days
  receive_wait_time_seconds   = 10     # Enable long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.fifo_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "lab-fifo-queue.fifo"
    Environment = "dev"
  }
}

# ==========================================
# 3. SNS Topic (Lab 12 - Fan-Out)
# ==========================================

# Standard SNS Topic - acts as the central message broker in the fan-out pattern.
# Publishers send ONE message here; SNS delivers it to ALL subscribers simultaneously.
resource "aws_sns_topic" "lab_orders" {
  name = "lab-orders"

  tags = {
    Name        = "lab-orders"
    Environment = "dev"
    Lab         = "12-sns"
  }
}

# ==========================================
# 4. SNS → SQS Subscription (Fan-Out Leg A)
# ==========================================

# Subscribe the existing lab-standard-queue to the SNS topic.
# SNS will push messages here in addition to any other subscribers (fan-out).
resource "aws_sns_topic_subscription" "orders_to_sqs" {
  topic_arn = aws_sns_topic.lab_orders.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.standard_queue.arn

  # raw_message_delivery = true strips the SNS envelope JSON wrapper.
  # Set to false (default) so we can inspect the full SNS metadata in the lab.
  raw_message_delivery = false
}

# ==========================================
# 5. SNS → Email Subscription (Fan-Out Leg B - optional)
# ==========================================

# Only create this subscription if sns_email_endpoint is set (non-empty).
# Requires manual inbox confirmation before it becomes active.
resource "aws_sns_topic_subscription" "orders_to_email" {
  count = var.sns_email_endpoint != "" ? 1 : 0

  topic_arn = aws_sns_topic.lab_orders.arn
  protocol  = "email"
  endpoint  = var.sns_email_endpoint
}

# ==========================================
# 6. SQS Queue Policy - Allow SNS to send messages
# ==========================================

# Without this policy, SNS cannot deliver messages to the SQS queue.
# The policy grants the SNS topic (identified by its ARN) the sqs:SendMessage
# action, but ONLY for messages originating from our specific topic (Condition).
resource "aws_sqs_queue_policy" "standard_queue_sns_policy" {
  queue_url = aws_sqs_queue.standard_queue.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSNSToSendMessage"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.standard_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.lab_orders.arn
          }
        }
      }
    ]
  })
}
