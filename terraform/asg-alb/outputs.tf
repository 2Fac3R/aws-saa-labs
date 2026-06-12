output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The domain name of the load balancer"
}

output "alb_arn_suffix" {
  value       = aws_lb.main.arn_suffix
  description = "The ARN Suffix of the Load Balancer (for CloudWatch)"
}

output "asg_name" {
  value       = aws_autoscaling_group.web.name
  description = "The name of the Auto Scaling Group"
}

output "asg_sg_id" {
  value       = aws_security_group.asg_sg.id
  description = "The Security Group ID of the ASG instances"
}
