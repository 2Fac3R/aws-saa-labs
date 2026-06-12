output "kms_key_arn" {
  value = aws_kms_key.lab_key.arn
}

output "kms_key_id" {
  value = aws_kms_key.lab_key.key_id
}

output "secret_arn" {
  value = aws_secretsmanager_secret.secure_app_secret.arn
}
