provider "aws" {
  region = var.aws_region
}

# --- DynamoDB Table (Serverless NoSQL) ---
resource "aws_dynamodb_table" "lab_table" {
  name         = "lab-orders-table"
  billing_mode = "PAY_PER_REQUEST" # Serverless / On-Demand

  # The attributes must be defined here
  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
    name = "Status"
    type = "S"
  }

  # Primary Key Definition (Top-level)
  hash_key  = "PK"
  range_key = "SK"

  # --- Global Secondary Index (GSI) ---
  global_secondary_index {
    name            = "StatusIndex"
    projection_type = "ALL"

    key_schema {
      attribute_name = "Status"
      key_type       = "HASH"
    }

    key_schema {
      attribute_name = "PK"
      key_type       = "RANGE"
    }
  }

  # --- Time to Live (TTL) ---
  ttl {
    attribute_name = "ExpiresAt"
    enabled        = true
  }

  tags = {
    Name        = "lab-orders-table"
    Environment = "Dev"
  }
}

