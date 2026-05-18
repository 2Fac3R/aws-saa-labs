# Lab 10: ECS Fargate & GitHub CI/CD (OIDC)

## Objective
Establish a secure, modern CI/CD pipeline foundation for containerized applications using an Application Load Balancer (ALB) and GitHub OIDC.

## Architecture
![Lab 10 Architecture](../diagrams/lab-10-ecs-ci.svg)

## Key Concepts

### 1. GitHub OIDC Federation (Security Pillar)
Instead of creating an IAM User and storing Access Keys as GitHub Secrets (which can leak), we use **OpenID Connect (OIDC)**.
- **How it works:** AWS trusts GitHub's identity provider. AWS verifies the token from GitHub and allows the pipeline to assume a specific IAM Role (`github-actions-ecs-deploy-role`).
- **SAA Focus:** This is the most secure way to handle cross-cloud authentication.

### 2. Application Load Balancer (ALB)
The ALB provides a stable public DNS name and distributes traffic to the ECS Fargate tasks running in private subnets.
- **Health Checks:** The ALB ensures that traffic is only sent to "healthy" containers.
- **Port Mapping:** Users access the ALB on port 80, which forwards traffic to the containers on port 8000.

### 3. ECS Fargate & Security in Depth
- **Private Subnets:** Containers have no public IPs; they are isolated for maximum security.
- **Security Group Chaining:** The ECS Service Security Group is restricted to **only** allow traffic from the ALB's Security Group.
- **Task & Execution Roles:** We use unique roles (`engineering-mastery-ecs-*`) to provide specific permissions for image pulling and log streaming.

### 4. Shared Responsibility in CI/CD
- **Terraform:** Manages the infrastructure "plumbing" (ALB, Cluster, Roles, ECR).
- **GitHub Actions:** Manages the application lifecycle (Build, Push, rolling update of the service).

## Implementation Details
- **Cluster Name:** `engineering-mastery-cluster`
- **Service Name:** `mastery-lab-service`
- **Container Port:** 8000
- **Public URL:** Provided by the ALB DNS Name.

## SAA Exam Takeaways
- **OIDC** is the best practice for third-party CI/CD integrations.
- **ALBs** are required to expose private Fargate tasks to the internet.
- **Security Group Chaining** is a fundamental design pattern for multi-tier apps.
