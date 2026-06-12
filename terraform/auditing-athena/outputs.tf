output "cloudtrail_bucket" {
  value = aws_s3_bucket.cloudtrail_logs.id
}

output "athena_workgroup" {
  value = aws_athena_workgroup.main.name
}
