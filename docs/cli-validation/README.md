# Lab Dependency Map

Since this project uses a highly modularized approach, certain labs require other foundational layers to be active. Use this map to identify what needs to be "Up" (applied) before testing or deploying a specific lab.

| Lab | Name | Required Dependencies (Must be "Up") | Notes |
| :--- | :--- | :--- | :--- |
| **0** | Bootstrap | None | Stores the state for everything else. **NEVER DESTROY.** |
| **1** | IAM | Lab 0 | Provides the S3 bucket used as a "Code Repo". |
| **2** | Networking | Lab 0 | The VPC backbone. |
| **3** | EC2 Single | Lab 0, 1, 2 | Uses IAM Role and VPC Subnets. |
| **4** | ASG + ALB | Lab 0, 1, 2 | Uses IAM Role and VPC Subnets. |
| **5** | S3 + CloudFront | Lab 0 | Independent of VPC. |
| **6** | EBS / EFS | Lab 0, 2, 4 | Needs VPC for Mount Targets and ASG for Mount verification. |
| **7** | RDS | Lab 0, 2 | Needs VPC Private Subnets. |
| **8** | DynamoDB | Lab 0 | Independent of VPC. |
| **9** | Lambda + APIGW | Lab 0, 1, 8 | Uses Lab 1 S3 bucket for code and Lab 8 Table for data. |
| **10** | ECS + CI/CD | Lab 0, 2 | Needs VPC for Fargate and ALB. |
| **11** | SQS | Lab 0 | Messaging foundation. |
| **12** | SNS | Lab 0, 11 | Pub/Sub fan-out (needs SQS for integration). |
| **13** | EventBridge | Lab 0, 1 | Buses and Scheduled events. |
| **14** | CloudWatch | Lab 0, 4, 12 | Needs ASG/ALB for metrics and SNS for alarms. |
| **15** | CloudTrail & Athena | Lab 0 | Independent auditing and analysis layer. |
| **16** | KMS & Secrets Manager | Lab 0 | Security foundation for encryption and secrets. |

## Cost Optimization Tip
If you are destroying infrastructure to save costs, always keep **Lab 0 (Bootstrap)** alive. When moving to a specific phase, re-apply **Lab 2 (Networking)** first, as it is the most common dependency.
