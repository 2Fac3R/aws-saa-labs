provider "aws" {
  region = var.aws_region
}

# --- Remote State Lookups ---
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "aws-saa-labs-tfstate-444386042261-us-east-1"
    key    = "iam/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "dynamodb" {
  backend = "s3"
  config = {
    bucket = "aws-saa-labs-tfstate-444386042261-us-east-1"
    key    = "databases-dynamodb/terraform.tfstate"
    region = "us-east-1"
  }
}

# --- Packaging Lambda Code ---
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../../apps/lambda-functions/handler.py"
  output_path = "lambda_function_payload.zip"
}

# --- S3 Upload (Architect Way) ---
resource "aws_s3_object" "lambda_code" {
  bucket = data.terraform_remote_state.iam.outputs.s3_bucket_name
  key    = "lambdas/handler.zip"
  source = data.archive_file.lambda_zip.output_path
  etag   = filemd5(data.archive_file.lambda_zip.output_path)
}

# --- IAM Role for Lambda ---
resource "aws_iam_role" "lambda_exec" {
  name = "lab-lambda-dynamo-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy to write to DynamoDB
resource "aws_iam_policy" "lambda_dynamo" {
  name = "LambdaDynamoDBWritePolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["dynamodb:PutItem"]
      Effect   = "Allow"
      Resource = data.terraform_remote_state.dynamodb.outputs.table_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_dynamo.arn
}

# --- Lambda Function ---
resource "aws_lambda_function" "order_processor" {
  function_name = "lab-order-processor"
  s3_bucket     = data.terraform_remote_state.iam.outputs.s3_bucket_name
  s3_key        = aws_s3_object.lambda_code.key
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_exec.arn

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = data.terraform_remote_state.dynamodb.outputs.table_name
    }
  }
}

# --- API Gateway (REST API) ---
resource "aws_api_gateway_rest_api" "order_api" {
  name        = "lab-order-api"
  description = "Serverless Order API"
}

resource "aws_api_gateway_resource" "orders" {
  rest_api_id = aws_api_gateway_rest_api.order_api.id
  parent_id   = aws_api_gateway_rest_api.order_api.root_resource_id
  path_part   = "orders"
}

resource "aws_api_gateway_method" "post_order" {
  rest_api_id   = aws_api_gateway_rest_api.order_api.id
  resource_id   = aws_api_gateway_resource.orders.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.order_api.id
  resource_id = aws_api_gateway_resource.orders.id
  http_method = aws_api_gateway_method.post_order.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.order_processor.invoke_arn
}

resource "aws_api_gateway_deployment" "main" {
  depends_on  = [aws_api_gateway_integration.lambda]
  rest_api_id = aws_api_gateway_rest_api.order_api.id

  # Forces a new deployment when the API changes
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.order_api))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.order_api.id
  stage_name    = "prod"
}

# --- Lambda Permission for API Gateway ---
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.order_processor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.order_api.execution_arn}/*/*"
}
