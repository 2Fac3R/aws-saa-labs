# Lab 7: RDS (PostgreSQL & Multi-AZ) with Secrets Manager

## Objective
Deploy a highly available, managed relational database and implement secure credential management using AWS Secrets Manager.

## Architecture
![Lab 7 Architecture](../diagrams/lab-7-rds.svg)

## Key Concepts

### 1. Amazon RDS (Relational Database Service)
RDS is a managed service that makes it easy to set up, operate, and scale a relational database in the cloud. It handles routine tasks like patching, backups, and failover.

### 2. Multi-AZ Deployment (High Availability)
- **Synchronous Replication:** Data is simultaneously written to a primary instance and a standby instance in a different Availability Zone (AZ).
- **Automatic Failover:** If the primary instance fails, RDS automatically flips the DNS record to point to the standby instance. This typically takes 1-2 minutes.
- **SAA Focus:** Multi-AZ is for **Disaster Recovery** and high availability, not for scaling read traffic (that's what Read Replicas are for).

### 3. AWS Secrets Manager
Instead of hardcoding database passwords in your application code or environment variables, you store them in Secrets Manager.
- **Security:** Credentials are encrypted at rest (using KMS).
- **Rotation:** Supports automatic rotation of passwords.
- **Service Integration:** Applications use the AWS SDK to fetch the secret at runtime.

### 4. DB Subnet Group
A collection of subnets (typically private) that you designate for your RDS instances in a VPC. It must contain subnets from at least two Availability Zones in the region.

## Implementation Details
- **Engine:** PostgreSQL 15
- **Instance Class:** db.t3.micro (Free Tier eligible)
- **Security:** Port 5432 allowed from the VPC CIDR (10.0.0.0/16).
- **Storage:** 20GB General Purpose SSD (gp2/gp3).

## SAA Exam Takeaways
- **Multi-AZ = High Availability** (Synchronous replication, automatic failover).
- **Read Replicas = Scalability** (Asynchronous replication, offload read traffic).
- **Secrets Manager** is the best practice for storing DB credentials and supports rotation.
- RDS is a **Regional** service, but the instances live in specific subnets (AZs).
