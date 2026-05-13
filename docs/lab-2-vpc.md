# Lab 2: VPC Foundations (Multi-AZ Networking)

## Objective
Build a production-ready, highly available network architecture with public and private segmentation, NAT capabilities, and optimized service access.

## Architecture
![Lab 2 Architecture](../diagrams/lab-2-vpc.svg)

## Key Concepts

### 1. Multi-AZ Subnetting
We deployed subnets across two **Availability Zones (AZs)**. This is the cornerstone of High Availability (HA) in AWS. If one AZ (physical data center) fails, the resources in the other AZ remain operational.

### 2. Public vs. Private Subnets
- **Public Subnets:** Point their default route (`0.0.0.0/0`) to an **Internet Gateway (IGW)**. They are used for resources that must be reachable from the internet (e.g., Load Balancers).
- **Private Subnets:** Point their default route to a **NAT Gateway**. They are used for resources that should never be directly accessible from the internet (e.g., Databases, App Servers).

### 3. NAT Gateway
A managed service that allows instances in a private subnet to connect to the internet (for updates, etc.) but prevents the internet from initiating a connection with those instances. It resides in a **Public Subnet** and requires an **Elastic IP**.

### 4. VPC Endpoint (Gateway Type)
The **S3 Gateway Endpoint** provides a secure, private connection to S3 without requiring a NAT Gateway or Internet Gateway.
- **Cost Saving:** Traffic through the endpoint is free, whereas traffic through a NAT Gateway incurs data processing charges.
- **Security:** Traffic never leaves the Amazon network backbone.
- **Implementation:** It updates the route tables with a "Prefix List" for S3.

## Implementation Details
- **CIDR:** `10.0.0.0/16`
- **Availability Zones:** 2 (us-east-1a, us-east-1b)
- **Gateways:** 1 IGW, 1 NAT Gateway
- **Endpoint:** 1 S3 Gateway Endpoint (Associated with all route tables)

## SAA Exam Takeaways
- Use **Multi-AZ** for High Availability.
- **NAT Gateways** are for private subnet outbound traffic.
- **VPC Endpoints** (Gateway for S3/DynamoDB) are preferred over NAT Gateways for cost and performance.
- A **Public IP** and an **Internet Gateway** are both required for internet connectivity in a public subnet.
