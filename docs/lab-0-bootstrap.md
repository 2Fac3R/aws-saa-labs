# Lab 0: Terraform Bootstrap (State Management)

## Objective
Establish a secure, persistent, and collaborative foundation for Infrastructure as Code using AWS S3 for state storage and DynamoDB for state locking.

## Architecture
![Lab 0 Architecture](../diagrams/lab-0-bootstrap.svg)

## Key Concepts

### 1. Remote State Storage (S3)
By default, Terraform stores state locally in a `terraform.tfstate` file. In a team or production environment, this is dangerous because:
- Multiple people might overwrite each other's changes.
- Sensitive data is stored in plain text on local disks.
- The state file is lost if the local disk fails.

Moving state to **S3** provides durability (99.999999999%), versioning (to recover from accidental corruption), and encryption at rest.

### 2. State Locking (DynamoDB)
To prevent two people from running `terraform apply` at the same time, Terraform uses a **Lock Table** in DynamoDB. Before any modification, Terraform acquires a lock; once complete, it releases it. If someone else tries to run an update while the lock is held, Terraform will exit with an error.

### 3. "Chicken and Egg" Problem
We use Terraform to create the S3 bucket and DynamoDB table. Initially, this "bootstrap" module uses **local state**. Once the resources are created, we re-initialize the bootstrap module to migrate its own state into the bucket it just created.

## Implementation Details
- **S3 Bucket:** `aws-saa-labs-tfstate-444386042261-us-east-1`
- **DynamoDB Table:** `aws-saa-labs-tfstate-locks`
- **Security:** Enabled S3 Versioning, Server-Side Encryption (AES256), and Blocked All Public Access.

## SAA Exam Takeaways
- **S3 + DynamoDB** is the standard AWS architecture for Terraform state.
- Remote backends are critical for **concurrency control** and **security**.
- State files can contain secrets (like DB passwords), so the S3 bucket must be private and encrypted.
