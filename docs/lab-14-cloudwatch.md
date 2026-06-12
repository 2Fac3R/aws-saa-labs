# Lab 14: Amazon CloudWatch (Monitoring & Alerting)

## Objective
Implement a centralized observability layer to monitor the health, performance, and operational integrity of the infrastructure. This lab integrates metrics from the ASG and ALB into automated alarms and visual dashboards.

## Architecture
![Lab 14 Architecture](../diagrams/lab-14-cloudwatch.svg)

## Key Concepts

### 1. CloudWatch Metrics and Alarms
CloudWatch collects data from AWS resources in the form of **Metrics**.
- **Metric Alarms:** Watch a single metric over a specified time period and perform one or more actions based on the value of the metric relative to a threshold.
- **Evaluation Periods:** We configured alarms to trigger only after multiple consecutive violations to prevent "flapping" (unnecessary alerts from temporary spikes).

### 2. CloudWatch Dashboards
Customizable home pages in the CloudWatch console that provide a visual representation of your resources. They can display metrics from multiple regions and services in a single view.

### 3. Log Management
CloudWatch Logs allows you to centralize the logs from all your systems, applications, and AWS services.
- **Retention Policies:** We configured a 14-day retention to balance visibility with cost optimization.

### 4. Integration with SNS
By linking alarms to the **SNS Topic from Lab 12**, we create an automated notification loop. When a server's CPU exceeds 80% or the ALB encounters errors, the administrator is notified immediately via email.

## Implementation Details
- **Dashboard:** `Lab-Architecture-Overview` (Visualizing ASG CPU and ALB Request Count).
- **CPU Alarm:** `lab-asg-high-cpu` (>80% over 4 minutes).
- **ALB Error Alarm:** `lab-alb-high-errors` (>10 errors in 1 minute).
- **Centralized Log Group:** `/aws/app/lab-custom-events`.

## SAA Exam Takeaways
- **CloudWatch Alarms** are the primary way to trigger **Auto Scaling** actions or **SNS** notifications.
- **CloudWatch Events** (now EventBridge) are for responding to state changes, while **CloudWatch Alarms** are for responding to metric thresholds.
- **High-Resolution Metrics:** Can be provided at 1-second intervals (standard is 1 or 5 minutes).
- **Custom Metrics:** You can send your own application metrics to CloudWatch using the SDK.
