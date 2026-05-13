# AWS SAA Practical Training - Project Instructions

## Core Mandates
* **IaC-First:** Every AWS resource MUST be created via Terraform. Manual console usage is for visualization and debugging only.
* **Surgical Execution:** Follow the phases in `AWS SAA Practical Training.md` sequentially.
* **Validation:** Every lab must be validated (e.g., via Python scripts, CLI commands, or connectivity tests).
* **Architecture Documentation:** Update `diagrams/` or `docs/` when significant architectural changes are made.

## Workflow
1. **Research:** Understand the specific AWS service and Terraform resources for the current lab.
2. **Implementation:** Provision infrastructure in the corresponding `terraform/` subdirectory.
3. **Application:** Deploy any required code in `apps/`.
4. **Validation:** Run tests to confirm the infrastructure works as intended.
5. **Documentation:** Record key takeaways and concept explanations in `docs/`.

## Terraform Conventions
* **App Deployment:** Use S3 as the source of truth. Upload app code to S3 and fetch it via IAM Roles in User Data.
* **Remote Backend:** Configuration is stored in S3 (`aws-saa-labs-tfstate-444386042261-us-east-1`) with DynamoDB locking (`aws-saa-labs-tfstate-locks`).
* **Module Backend:** Use `terraform/backend.tf.example` as a template for new modules.
* **Organization:** Organize resources logically into files (e.g., `vpc.tf`, `iam.tf`, `outputs.tf`).
* **Reusability:** Prefer modules for reusable components.
