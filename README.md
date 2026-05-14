# AWS Solutions Architect Associate (SAA) Practical Training

This repository contains a hands-on, laboratory-based curriculum designed to master AWS cloud architecture. It follows the SAA-C03 exam domains using an Infrastructure-as-Code (IaC) first approach.

## 🚀 Core Mandates

Defined in [GEMINI.md](./GEMINI.md), these principles guide every laboratory:

*   **IaC-First:** Every AWS resource MUST be created via Terraform. Manual console usage is for visualization and debugging only.
*   **Surgical Execution:** Follow the phases sequentially to build complex architectures step-by-step.
*   **Validation:** Every lab is verified using automated scripts (Python) or CLI connectivity tests.
*   **Architecture Documentation:** Visual diagrams and detailed documentation accompany every lab.

## 📂 Project Structure

*   `terraform/`: Infrastructure modules organized by lab/service.
*   `apps/`: Application code (FastAPI, Lambda, Workers) deployed onto the infrastructure.
*   `docs/`: Detailed lab guides, concept explanations, and validation steps.
*   `diagrams/`: Architectural diagrams (D2/SVG) for each phase.
*   `scripts/`: Utility scripts for environment management and validation.

## 🗺️ Lab Roadmap

### Phase 1: Foundations
- [x] **0. Bootstrap** - Remote state management (S3 + DynamoDB).
- [x] **1. IAM** - Roles, Policies, and Instance Profiles (EC2 to S3 access).
- [x] **2. Networking** - VPC, Subnets, Gateways, and VPC Endpoints (Gateway & Interface).

### Phase 2: Compute & Traffic Management
- [ ] **3. EC2** - Launch Templates, User Data bootstrapping, and FastAPI deployment.
- [ ] **4. HA & Routing** - ALB, Auto Scaling Groups (ASG), and Route 53 Routing Policies.

### Phase 3: Storage & Content Delivery
- [ ] **5. S3 & CloudFront** - Lifecycle rules, Replication, and OAC (Origin Access Control).
- [ ] **6. EBS & EFS** - Block vs. File storage with multi-instance shared access.

### Phase 4: Databases
- [ ] **7. RDS & Aurora** - Multi-AZ, Read Replicas, and failover behavior.
- [ ] **8. DynamoDB** - NoSQL modeling, GSIs, and TTL configurations.

### Phase 5: Serverless & Containers
- [ ] **9. Lambda & API Gateway** - Event-driven processing and serverless APIs.
- [ ] **10. ECS Fargate** - Managed container orchestration for microservices.

### Phase 6: Messaging & Integration
- [ ] **11. SQS** - Standard vs. FIFO queues, DLQs, and visibility timeouts.
- [ ] **12. SNS** - Pub/Sub fan-out architectures.
- [ ] **13. EventBridge** - Event buses and scheduled jobs.

### Phase 7: Observability & Security
- [ ] **14. CloudWatch** - Metrics, Logs, Alarms, and Dashboards.
- [ ] **15. Auditing** - CloudTrail activity tracking and Athena log analysis.
- [ ] **16. Key Management** - KMS (Envelope Encryption) and Secrets Manager.
- [ ] **17. Edge Security** - WAF and Shield basics.

### Phase 8: Optimization & Final Project
- [ ] **18. HA/DR** - Multi-Region failover and RTO/RPO strategies.
- [ ] **19. Governance** - AWS Budgets, Cost Explorer, and SCPs.
- [ ] **Final Project** - A production-grade, highly available 3-tier application integrating all core domains.

## 🛠️ Getting Started

### Prerequisites
*   AWS CLI installed and configured with `AdministratorAccess`.
*   Terraform (v1.0+).
*   Python 3.10+ for validation scripts.

### Initialization
1.  Navigate to `terraform/bootstrap`.
2.  Run `terraform init` and `terraform apply`.
3.  Use the outputs to configure `terraform/backend.tf` for all subsequent labs (see `terraform/backend.tf.example`).

## 🔄 Workflow

1.  **Research:** Analyze the AWS service and Terraform resources.
2.  **Implementation:** Provision infrastructure in the corresponding `terraform/` subdirectory.
3.  **Application:** Deploy required code from `apps/`.
4.  **Validation:** Run tests to confirm the setup (e.g., `python apps/validation/s3_check.py`).
5.  **Documentation:** Update the corresponding lab guide in `docs/`.

---
*Follow the progress in [docs/](./docs/) for detailed walkthroughs.*
