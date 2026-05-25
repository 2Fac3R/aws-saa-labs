output "api_url" {
  value       = "${aws_api_gateway_stage.prod.invoke_url}/orders"
  description = "The URL to send POST requests to"
}
