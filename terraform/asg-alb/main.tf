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
resource "aws_s3_object" "app_code" {
  bucket = data.terraform_remote_state.iam.outputs.s3_bucket_name
  key    = "app-v2/main.py"
  source = "../../apps/fastapi-monolith/main.py"
  etag   = filemd5("../../apps/fastapi-monolith/main.py")
}

# --- Security Groups ---
# ALB Security Group (Public)
resource "aws_security_group" "alb_sg" {
  name        = "lab-alb-sg"
  description = "Allow HTTP from anywhere"
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

  tags = { Name = "lab-alb-sg" }
}

# Instance Security Group (Private)
resource "aws_security_group" "asg_sg" {
  name        = "lab-asg-sg"
  description = "Allow HTTP only from ALB"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "lab-asg-sg" }
}

# --- Application Load Balancer ---
resource "aws_lb" "main" {
  name               = "lab-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.terraform_remote_state.networking.outputs.public_subnet_ids

  tags = { Name = "lab-alb" }
}

resource "aws_lb_target_group" "web" {
  name     = "lab-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.networking.outputs.vpc_id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# --- Auto Scaling Group ---
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "asg" {
  name_prefix   = "lab-asg-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = "ec2-s3-access-profile"
  }

  vpc_security_group_ids = [aws_security_group.asg_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y python3-pip aws-cli
              pip3 install fastapi uvicorn boto3
              mkdir -p /app
              aws s3 cp s3://${data.terraform_remote_state.iam.outputs.s3_bucket_name}/app-v2/main.py /app/main.py
              cd /app
              nohup uvicorn main:app --host 0.0.0.0 --port 80 > /var/log/app.log 2>&1 &
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "Lab-4-ASG-Instance" }
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "lab-web-asg"
  vpc_zone_identifier = data.terraform_remote_state.networking.outputs.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.asg.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Lab-4-ASG-Instance"
    propagate_at_launch = true
  }
}
