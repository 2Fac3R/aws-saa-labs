output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The domain name of the load balancer"
}

output "asg_sg_id" {
  value       = aws_security_group.asg_sg.id
  description = "The Security Group ID of the ASG instances"
}
