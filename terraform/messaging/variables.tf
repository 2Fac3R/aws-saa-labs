variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Optional: Set this to an email address in terraform.tfvars to enable email subscription.
# Leave empty ("") to skip (requires manual inbox confirmation anyway).
variable "sns_email_endpoint" {
  type        = string
  description = "Email address for the SNS email subscription (optional, leave empty to skip)"
  default     = ""
}
