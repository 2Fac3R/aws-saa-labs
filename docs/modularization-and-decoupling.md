# Infrastructure Modularization & Decoupling

## The Strategy
In this project, we intentionally split our infrastructure into discrete, independent modules:
- `terraform/bootstrap`: The foundation (S3/DynamoDB for state).
- `terraform/networking`: The virtual data center (VPC, Subnets, Gateways).
- `terraform/iam`: Identity and access management.
- `terraform/compute`: Initial compute experiments.
- `terraform/asg-alb`: Highly available, auto-scaling compute.
- `terraform/storage`: Centralized assets and CDN delivery.
- `terraform/storage-efs`: Shared POSIX filesystem for clusters.
- `terraform/databases-rds`: Managed relational database (PostgreSQL).
- `terraform/databases-dynamodb`: Serverless NoSQL database.
- `terraform/serverless-api`: Serverless compute and REST API Gateway.
- `terraform/ecs-fargate-ci`: Container orchestration and CI/CD foundation.

## Why Decouple?

### 1. Independent Lifecycles
You can destroy and recreate your application servers (`compute`) without touching your database or networking. This is critical for cost management and rapid iteration.

### 2. Reduced Blast Radius
If you make a mistake in the `compute` module, you risk breaking the app, but you won't accidentally delete your VPC or IAM roles.

### 3. Separation of Concerns
Networking teams can manage the VPC, while developers manage the EC2 instances. Each team only interacts with their relevant state.

## How it works: `terraform_remote_state`
Since the modules are in different folders, they don't share variables. We use the `terraform_remote_state` data source to "peek" into the outputs of another module.

### Example:
The `compute` module needs a `subnet_id` from the `networking` module:

```hcl
# In compute/main.tf
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "aws-saa-labs-tfstate-..."
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "web" {
  # We reach into the networking state to get the ID
  subnet_id = data.terraform_remote_state.networking.outputs.public_subnet_ids[0]
}
```

## Connectivity & Optimization: VPC Endpoints
While modules are decoupled, they share a highly optimized networking backbone.

### S3 Gateway Endpoint
In `terraform/networking`, we provision a **VPC Gateway Endpoint for S3**. This architectural decision provides immediate benefits to **every other module** in the project:
1. **Cost Efficiency:** Any module fetching code from S3 (Labs 1, 3, 4, 9, 10) does so for free. Traffic bypasses the NAT Gateway, avoiding data processing charges.
2. **Security:** Data transfer remains entirely within the AWS private network. Traffic never traverses the public internet.
3. **Performance:** Direct connectivity to S3 results in faster bootstrapping for EC2 and Fargate tasks.

## Architectural Lessons: The Dependency Trap
Modularization is powerful but introduces the risk of **Circular Dependencies**. 

### The Challenge (Lab 6 Case Study)
In Lab 6, we tried to have the ASG module depend on the EFS ID, while the EFS module depended on the ASG Security Group ID. This created a loop where neither could be applied first.

### The Solution: Decoupled Connectivity
To break the loop, we shifted from **Security Group Chaining** (Least Privilege) to **CIDR-based Rules** (Functional Modularity).
- **Standard:** Instead of allowing a specific SG, we allow the **Private Subnet CIDR** range. 
- **Benefit:** This allows foundational storage (EFS, RDS) to be applied and tested independently of the compute cluster.

## SAA Exam Relevance: "Loosely Coupled"
A core tenet of the AWS Well-Architected Framework is **Loose Coupling**. By breaking your infrastructure into layers and managing dependencies carefully, you can scale, secure, and evolve each part independently.
