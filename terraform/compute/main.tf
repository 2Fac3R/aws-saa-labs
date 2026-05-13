provider "aws" {
  region = var.aws_region
}

# --- Remote State Lookups ---
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "aws-saa-labs-tfstate-444386042261-us-east-1"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "aws-saa-labs-tfstate-444386042261-us-east-1"
    key    = "iam/terraform.tfstate"
    region = "us-east-1"
  }
}

# --- S3 App Deployment ---
# Using the bucket created in Lab 1
resource "aws_s3_object" "app_code" {
  bucket = data.terraform_remote_state.iam.outputs.s3_bucket_name
  key    = "app/main.py"
  source = "../../apps/fastapi-monolith/main.py"
  etag   = filemd5("../../apps/fastapi-monolith/main.py")
}

# --- Security Group ---
resource "aws_security_group" "web_sg" {
  name        = "lab-web-sg"
  description = "Allow HTTP and SSH/SSM"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab-web-sg"
  }
}

# --- Launch Template ---
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "lab-web-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = "ec2-s3-access-profile"
  }

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # SAA Architect Way: Fetch from S3 using IAM Role
  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Update and install dependencies
              dnf update -y
              dnf install -y python3-pip git aws-cli
              
              # Install FastAPI and Uvicorn
              pip3 install fastapi uvicorn boto3
              
              # Create app directory and FETCH code from S3
              mkdir -p /app
              aws s3 cp s3://${data.terraform_remote_state.iam.outputs.s3_bucket_name}/app/main.py /app/main.py

              # Start the application
              cd /app
              nohup uvicorn main:app --host 0.0.0.0 --port 80 > /var/log/app.log 2>&1 &
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Lab-3-Web-Server"
    }
  }
}

# --- EC2 Instance (Single Instance for now) ---
resource "aws_instance" "web" {
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  subnet_id = data.terraform_remote_state.networking.outputs.public_subnet_ids[0]

  tags = {
    Name = "Lab-3-Web-Server"
  }
}

# --- Elastic IP ---
resource "aws_eip" "web_eip" {
  instance = aws_instance.web.id
  domain   = "vpc"

  tags = {
    Name = "lab-web-eip"
  }
}
