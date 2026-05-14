# Lab 4: High Availability (ALB + ASG)

## Objective
Evolve our single-instance architecture into a resilient, self-healing, and highly available system using an Application Load Balancer (ALB) and an Auto Scaling Group (ASG).

## Architecture
![Lab 4 Architecture](../diagrams/lab-4-asg-alb.svg)

## Key Concepts

### 1. Application Load Balancer (ALB)
The ALB serves as the single entry point for our users. It distributes incoming application traffic across multiple targets (EC2 instances) in multiple Availability Zones.
- **Health Checks:** The ALB periodically sends requests to the `/health` endpoint of each instance. If an instance fails, the ALB stops sending traffic to it.

### 2. Auto Scaling Group (ASG)
The ASG manages a collection of EC2 instances.
- **Self-Healing:** If an instance becomes unhealthy (as reported by the ALB), the ASG automatically terminates it and launches a new one.
- **Elasticity:** It can scale the number of instances up or down based on demand (though in this lab we use a fixed capacity of 2).
- **Multi-AZ Deployment:** The ASG is configured to launch instances across multiple private subnets in different AZs.

### 3. Security in Depth
- **Private Subnets:** Our application servers no longer have public IP addresses. They reside in private subnets, reachable only through the Load Balancer.
- **Security Group Chaining:** The `ASG-SG` is configured to allow inbound traffic **only** from the `ALB-SG`. This ensures that nobody can bypass the load balancer to talk directly to the instances.

### 4. S3-Based Deployment
Consistent with the "Architect Way," the ASG instances fetch the FastAPI code from S3 during their initial bootstrap.

## Implementation Details
- **ALB Type:** Internet-facing
- **ASG Capacity:** Min: 2, Desired: 2, Max: 4
- **Health Check Type:** ELB (checks target group health)
- **Subnets:** ALB in Public, ASG in Private

## SAA Exam Takeaways
- **High Availability:** Distribute workloads across multiple AZs.
- **Self-Healing:** Use ASGs with ELB health checks to automatically replace failed nodes.
- **Security:** Use private subnets for application servers and "chain" security groups to restrict access.
