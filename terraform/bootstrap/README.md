# Terraform Bootstrap

This directory contains the infrastructure required to manage Terraform state remotely and securely.

## Resources Created
*   **S3 Bucket:** Stores the `terraform.tfstate` files. Includes versioning and encryption.
*   **DynamoDB Table:** Handles state locking to prevent concurrent modifications.

## How to Deploy
1.  Ensure you have AWS credentials configured (`aws configure`).
2.  Initialize Terraform:
    ```bash
    terraform init
    ```
3.  Apply the configuration:
    ```bash
    terraform apply
    ```
4.  Note the outputs (bucket name and table name). These will be used in the `backend.tf` files for all subsequent labs.

## Note on State
This bootstrap module uses **local state** by default. While you can migrate its state to the S3 bucket it creates, it's often kept separate to avoid circular dependencies during initialization.
