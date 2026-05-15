output "table_name" {
  value = aws_dynamodb_table.lab_table.name
}

output "table_arn" {
  value = aws_dynamodb_table.lab_table.arn
}
