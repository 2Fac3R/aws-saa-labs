# Lab 6: EBS & EFS (Block vs. File Storage)

## Objective
Understand the performance and accessibility trade-offs between Amazon EBS (dedicated block storage) and Amazon EFS (shared network file storage).

## Architecture
![Lab 6 Architecture](../diagrams/lab-6-storage-block-file.svg)

## Key Concepts

### 1. Amazon EBS (Elastic Block Store)
EBS provides persistent block storage volumes for use with EC2 instances. 
- **Block Storage:** Behaves like a physical hard drive. It is formatted with a filesystem (EXT4, XFS) and mounted.
- **Dedicated:** Standard volumes are attached to a **single** EC2 instance in the **same** Availability Zone.
- **Snapshots:** Incremental backups stored in S3. Critical for disaster recovery.

### 2. Amazon EFS (Elastic File System)
EFS is a managed NFS (Network File System) that provides shared storage.
- **File Storage:** POSIX-compliant, meaning multiple instances can read/write to the same folder simultaneously.
- **Regional:** Accessible across multiple Availability Zones via **Mount Targets**.
- **Serverless:** Scales automatically with your data; you only pay for what you use.

### 3. NFS Security (Port 2049)
To access EFS, the instance's Security Group must allow outbound traffic on Port 2049, and the EFS Security Group must allow inbound traffic on the same port from the instances.

## Implementation Details
- **EBS Surgery:** Attached a secondary \`gp3\` volume to the Lab 3 EC2 instance and took a manual snapshot.
- **EFS Setup:** Provisioned a regional filesystem with mount targets in private subnets across 2 AZs.
- **ASG Integration:** Updated the Lab 4 Auto Scaling Group to automatically install \`amazon-efs-utils\` and mount the drive at \`/var/www/shared\` on boot.

## SAA Exam Takeaways
- **Use EBS** when you need low-latency, high-performance storage for a single instance (e.g., Databases).
- **Use EFS** when you need shared storage for a fleet of servers (e.g., Content Management Systems, shared media repositories).
- EBS is AZ-specific; EFS is regional.
