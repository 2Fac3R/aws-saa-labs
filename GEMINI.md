# AWS SAA Practical Training - Project Instructions

## Core Mandates
* **IaC-First:** Every AWS resource MUST be created via Terraform. Manual console usage is for visualization and debugging only.
* **Surgical Execution:** Follow the phases in `AWS SAA Practical Training.md` sequentially.
* **Checklist for Finality:** A lab is only considered complete when:
    1. **Code:** Terraform is fully applied and working.
    2. **D2:** Architecture diagram is updated and rendered to SVG.
    3. **Draw.io:** The master `.drawio` file has a new, stylized page for the lab.
    4. **Docs:** Lab guide and CLI validation playbook are updated.
    5. **README:** The lab is marked as completed in the main Roadmap.
* **Dependency Management:** Favor **Loose Coupling** to prevent circular dependencies. If two modules depend on each other, break the loop by using broader network rules (e.g., VPC CIDRs) or a third "Link" module.
* **Validation:** Every lab must be validated (e.g., via Python scripts, CLI commands, or connectivity tests).
* **Architecture Documentation:** Update `diagrams/` or `docs/` when significant architectural changes are made.

## Workflow
1. **Research:** Understand the specific AWS service and Terraform resources for the current lab.
2. **Order of Operations:** Identify dependent modules and ensure their remote state is available (fully applied).
3. **Implementation:** Provision infrastructure in the corresponding `terraform/` subdirectory.
4. **Application:** Deploy any required code in `apps/` (treating S3 as the source of truth).
5. **Validation:** Run tests to confirm the infrastructure works as intended.
6. **Documentation:** Record key takeaways and update the **Lab Dependency Map**.

## Terraform Conventions
* **App Deployment:** Use S3 as the source of truth. Upload app code to S3 and fetch it via IAM Roles in User Data.
* **Remote Backend:** Configuration is stored in S3 (`aws-saa-labs-tfstate-444386042261-us-east-1`) with DynamoDB locking (`aws-saa-labs-tfstate-locks`).
* **Module Backend:** Use `terraform/backend.tf.example` as a template for new modules.
* **Organization:** Organize resources logically into files (e.g., `vpc.tf`, `iam.tf`, `outputs.tf`).
* **Reusability:** Prefer modules for reusable components.
