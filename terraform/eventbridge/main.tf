provider "aws" {
  region = var.aws_region
}

# --- Remote State Lookups ---
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "aws-saa-labs-tfstate-444386042261-us-east-1"
    key    = "iam/terraform.tfstate"
    region = "us-east-1"
  }
}

# --- Packaging Lambda Code ---
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../../apps/lambda-functions/cron_handler.py"
  output_path = "lambda_function_payload.zip"
}

# --- S3 Upload ---
resource "aws_s3_object" "lambda_code" {
  bucket = data.terraform_remote_state.iam.outputs.s3_bucket_name
  key    = "lambdas/cron_handler.zip"
  source = data.archive_file.lambda_zip.output_path
  etag   = filemd5(data.archive_file.lambda_zip.output_path)
}

# --- IAM Role for Lambda ---
resource "aws_iam_role" "lambda_exec" {
  name = "lab-eventbridge-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --- Lambda Function (Target 1 - Scheduled Job) ---
resource "aws_lambda_function" "cron_worker" {
  function_name = "lab-cron-worker"
  s3_bucket     = data.terraform_remote_state.iam.outputs.s3_bucket_name
  s3_key        = aws_s3_object.lambda_code.key
  handler       = "cron_handler.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_exec.arn

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  tags = {
    Name        = "lab-cron-worker"
    Environment = "dev"
    Lab         = "13-eventbridge"
  }
}

# --- EventBridge Scheduled Rule (Cron) ---
resource "aws_cloudwatch_event_rule" "cron_rule" {
  name                = "lab-cron-rule"
  description         = "Triggers every minute to run scheduled serverless job"
  schedule_expression = "rate(1 minute)"

  tags = {
    Name        = "lab-cron-rule"
    Environment = "dev"
    Lab         = "13-eventbridge"
  }
}

# --- EventBridge Scheduled Target ---
resource "aws_cloudwatch_event_target" "cron_target" {
  rule      = aws_cloudwatch_event_rule.cron_rule.name
  target_id = "TriggerLambdaCron"
  arn       = aws_lambda_function.cron_worker.arn
}

# --- Lambda Permission for EventBridge ---
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cron_worker.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_rule.arn
}

# ==========================================
# Event-Driven Architecture (Custom Bus & SQS)
# ==========================================

# --- Custom Event Bus ---
resource "aws_cloudwatch_event_bus" "custom_bus" {
  name = "lab-custom-bus"

  tags = {
    Name        = "lab-custom-bus"
    Environment = "dev"
    Lab         = "13-eventbridge"
  }
}

# --- Custom Bus Rule (Filter Order Events) ---
resource "aws_cloudwatch_event_rule" "custom_order_rule" {
  name           = "lab-order-rule"
  description    = "Filter and capture order creation events"
  event_bus_name = aws_cloudwatch_event_bus.custom_bus.name

  # Matches events published with:
  # - source = "custom.order.service"
  # - detail-type = "OrderCreated"
  event_pattern = jsonencode({
    source      = ["custom.order.service"]
    detail-type = ["OrderCreated"]
  })

  tags = {
    Name        = "lab-order-rule"
    Environment = "dev"
    Lab         = "13-eventbridge"
  }
}

# --- Target SQS Queue (Fan-Out / Event Sink) ---
resource "aws_sqs_queue" "eventbridge_queue" {
  name                      = "lab-eventbridge-queue"
  message_retention_seconds = 345600 # 4 days
  receive_wait_time_seconds = 10     # Long polling enabled

  tags = {
    Name        = "lab-eventbridge-queue"
    Environment = "dev"
    Lab         = "13-eventbridge"
  }
}

# --- SQS Queue Policy (Allow EventBridge Target to publish) ---
resource "aws_sqs_queue_policy" "eventbridge_queue_policy" {
  queue_url = aws_sqs_queue.eventbridge_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgeToSendMessage"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.eventbridge_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.custom_order_rule.arn
          }
        }
      }
    ]
  })
}

# --- Custom Bus Rule Target (SQS Queue) ---
resource "aws_cloudwatch_event_target" "custom_order_target" {
  event_bus_name = aws_cloudwatch_event_bus.custom_bus.name
  rule           = aws_cloudwatch_event_rule.custom_order_rule.name
  target_id      = "SendToSQSQueue"
  arn            = aws_sqs_queue.eventbridge_queue.arn
}
