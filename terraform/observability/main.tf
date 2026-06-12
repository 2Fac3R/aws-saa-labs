provider "aws" {
  region = var.aws_region
}

# --- Remote State Lookups ---
data "terraform_remote_state" "asg_alb" {
  backend = "s3"
  config = {
    bucket = "aws-saa-labs-tfstate-444386042261-us-east-1"
    key    = "asg-alb/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "messaging" {
  backend = "s3"
  config = {
    bucket = "aws-saa-labs-tfstate-444386042261-us-east-1"
    key    = "messaging/terraform.tfstate"
    region = "us-east-1"
  }
}

# --- 1. CloudWatch Log Group (Centralized Logging) ---
# Most services (Lambda, ECS) already have their own, but we can create a custom one for app events
resource "aws_cloudwatch_log_group" "app_events" {
  name              = "/aws/app/lab-custom-events"
  retention_in_days = 14
}

# --- 2. CloudWatch Metric Alarms (Alerting) ---

# Alarm for high CPU on ASG
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "lab-asg-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization exceeding 80%"

  dimensions = {
    AutoScalingGroupName = data.terraform_remote_state.asg_alb.outputs.asg_name
  }

  alarm_actions = [data.terraform_remote_state.messaging.outputs.sns_topic_arn]
}

# Alarm for ALB 5XX Errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "lab-alb-high-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alert when ALB 5XX errors exceed 10 in a minute"

  dimensions = {
    LoadBalancer = data.terraform_remote_state.asg_alb.outputs.alb_arn_suffix
  }

  alarm_actions = [data.terraform_remote_state.messaging.outputs.sns_topic_arn]
}

# --- 3. CloudWatch Dashboard (Visualization) ---
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "Lab-Architecture-Overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", data.terraform_remote_state.asg_alb.outputs.asg_name]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ASG CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", data.terraform_remote_state.asg_alb.outputs.alb_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "ALB Request Volume"
        }
      }
    ]
  })
}
