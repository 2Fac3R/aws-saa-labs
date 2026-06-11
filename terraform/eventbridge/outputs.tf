output "custom_bus_name" {
  value       = aws_cloudwatch_event_bus.custom_bus.name
  description = "The name of the custom EventBridge Event Bus"
}

output "custom_bus_arn" {
  value       = aws_cloudwatch_event_bus.custom_bus.arn
  description = "The ARN of the custom EventBridge Event Bus"
}

output "sqs_queue_url" {
  value       = aws_sqs_queue.eventbridge_queue.url
  description = "The URL of the target SQS queue for the custom bus rule"
}

output "sqs_queue_arn" {
  value       = aws_sqs_queue.eventbridge_queue.arn
  description = "The ARN of the target SQS queue for the custom bus rule"
}

output "lambda_function_arn" {
  value       = aws_lambda_function.cron_worker.arn
  description = "The ARN of the cron-triggered Lambda function"
}

output "lambda_function_name" {
  value       = aws_lambda_function.cron_worker.function_name
  description = "The name of the cron-triggered Lambda function"
}
