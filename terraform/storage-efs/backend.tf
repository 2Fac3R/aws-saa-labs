terraform {
  backend "s3" {
    bucket         = "aws-saa-labs-tfstate-444386042261-us-east-1"
    key            = "storage-efs/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aws-saa-labs-tfstate-locks"
    encrypt        = true
  }
}
