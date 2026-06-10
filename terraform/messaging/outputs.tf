output "standard_queue_url" {
  value       = aws_sqs_queue.standard_queue.url
  description = "The URL of the primary standard SQS queue"
}

output "standard_queue_arn" {
  value       = aws_sqs_queue.standard_queue.arn
  description = "The ARN of the primary standard SQS queue"
}

output "standard_dlq_url" {
  value       = aws_sqs_queue.standard_dlq.url
  description = "The URL of the standard Dead Letter Queue"
}

output "standard_dlq_arn" {
  value       = aws_sqs_queue.standard_dlq.arn
  description = "The ARN of the standard Dead Letter Queue"
}

output "fifo_queue_url" {
  value       = aws_sqs_queue.fifo_queue.url
  description = "The URL of the primary FIFO SQS queue"
}

output "fifo_queue_arn" {
  value       = aws_sqs_queue.fifo_queue.arn
  description = "The ARN of the primary FIFO SQS queue"
}

output "fifo_dlq_url" {
  value       = aws_sqs_queue.fifo_dlq.url
  description = "The URL of the FIFO Dead Letter Queue"
}

output "fifo_dlq_arn" {
  value       = aws_sqs_queue.fifo_dlq.arn
  description = "The ARN of the FIFO Dead Letter Queue"
}
