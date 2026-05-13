output "s3_bucket_name" {
  value = aws_s3_bucket.data_bucket.id
}

output "ec2_instance_id" {
  value = aws_instance.lab_ec2.id
}

output "iam_role_name" {
  value = aws_iam_role.ec2_s3_access_role.name
}
