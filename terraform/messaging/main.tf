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
