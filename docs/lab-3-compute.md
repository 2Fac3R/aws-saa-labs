# Lab 3: EC2 & Application Bootstrapping

## Objective
Deploy a functional, bootstrapped web server using Launch Templates, User Data, and persistent public addressing (Elastic IP).

## Architecture
![Lab 3 Architecture](../diagrams/lab-3-compute.svg)

## Key Concepts

### 1. Launch Templates (LT)
A Launch Template defines all the parameters for starting an EC2 instance (AMI, Instance Type, Key Pair, Security Groups, IAM Role).
- **SAA Focus:** LTs are versioned and are the modern replacement for Launch Configurations. They are required for features like Spot Fleet and advanced Auto Scaling.

### 2. User Data (Bootstrapping)
User Data allows you to provide a script that AWS executes automatically when the instance boots for the first time.
- **Workflow:** Install packages (Python, Git) -> Deploy Code (FastAPI) -> Start Service (Uvicorn).
- **Limit:** User Data only runs on the **initial boot**. If you reboot the instance, it does not run again (unless specifically configured to do so).

### 3. Elastic IP (EIP)
An Elastic IP is a static, IPv4 address designed for dynamic cloud computing.
- **Persistence:** Unlike a regular public IP, an EIP stays associated with your account until you release it. It remains mapped to your instance even if it's stopped/started.
- **Cost:** EIPs are free when attached to a running instance, but incur a small hourly charge when "idle" (allocated but not attached).

### 4. Cross-Module State Lookup
This lab uses `terraform_remote_state` to fetch networking and IAM outputs. This is how architects manage complex projects by splitting them into logical layers (Foundations vs. Compute).

## Implementation Details
- **AMI:** Amazon Linux 2023 (AL2023)
- **Instance Type:** t3.micro
- **App Stack:** Python 3.9+, FastAPI, Uvicorn
- **Security:** HTTP (80) allowed from 0.0.0.0/0.

## SAA Exam Takeaways
- **User Data** is for simple bootstrapping; **AMIs** (Gold Images) are for faster, complex scaling.
- **Elastic IPs** help with persistence but have service quotas (usually 5 per region).
- **Security Groups** are stateful; if you allow port 80 Inbound, the Outbound response is automatically allowed.
