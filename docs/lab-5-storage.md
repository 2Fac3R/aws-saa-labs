# Lab 5: S3 Advanced Features & CloudFront OAC

## Objective
Implement a secure, globally distributed storage solution using Amazon S3 with advanced management features and Amazon CloudFront for edge content delivery.

## Architecture
![Lab 5 Architecture](../diagrams/lab-5-storage.svg)

## Key Concepts

### 1. S3 Management
- **Versioning:** Enabled to protect against accidental overwrites and provides a history of object changes.
- **Lifecycle Rules:** Configured to automatically transition data to cheaper storage classes (**Standard-IA** and **Glacier**) to optimize costs as data ages.

### 2. Amazon CloudFront
CloudFront is a Content Delivery Network (CDN) that caches content at edge locations globally, reducing latency for end-users.

### 3. Origin Access Control (OAC)
OAC is the modern replacement for Origin Access Identity (OAI).
- **Security:** It allows you to keep your S3 bucket completely private (blocking all public access).
- **Service Integration:** CloudFront uses OAC to sign its requests to S3 using SigV4. The S3 bucket policy is then configured to only allow requests from the specific CloudFront distribution's service principal.

### 4. Storage Classes (SAA Exam Focus)
- **S3 Standard:** Frequent access.
- **S3 Standard-IA (Infrequent Access):** Lower cost storage, but charges for retrieval.
- **S3 Glacier Flexible Retrieval:** Archive data (minutes to hours retrieval).
- **S3 Glacier Deep Archive:** Long-term archive (12-48 hour retrieval).

## Implementation Details
- **Bucket Security:** All public access blocked.
- **Protocol Policy:** Redirect-to-HTTPS enforced at the CloudFront level.
- **Regional Domain Names:** Used for S3 origins to ensure OAC works correctly.

## SAA Exam Takeaways
- Use **OAC** over OAI for modern S3 origins.
- **Lifecycle Policies** are the primary way to automate cost optimization for storage.
- **Versioning** is required for **Cross-Region Replication (CRR)**.
- CloudFront improves performance by caching content at **Edge Locations**.
