# Lab 16: KMS & Secrets Manager (Security & Encryption)

## Objective
Master data protection and secret management using AWS Key Management Service (KMS) and AWS Secrets Manager. Implement "Envelope Encryption" and fine-grained access control via KMS Key Policies.

## Architecture
![Lab 16 Architecture](../diagrams/lab-16-security-kms.svg)

## Key Concepts

### 1. AWS Key Management Service (KMS)
KMS is a managed service that makes it easy for you to create and control the cryptographic keys used to protect your data.
- **Customer Managed Key (CMK):** Keys you create, manage, and use. You have full control over the key policy and rotation.
- **AWS Managed Key:** Created and managed by AWS services on your behalf. You cannot change the policy.

### 2. Key Policies
Key policies are the primary way to control access to customer managed keys. 
- **IAM is not enough:** To use a KMS key, a principal must be granted permission in BOTH their IAM policy and the KMS Key Policy (if the principal is in the same account).
- **External Accounts:** To grant access to an external account, you MUST use the Key Policy.

### 3. Envelope Encryption
The practice of encrypting data with a **Data Key**, and then encrypting the Data Key with a **Root Key** (KMS Key).
- Secrets Manager uses envelope encryption automatically. When you request a secret, Secrets Manager asks KMS to decrypt the data key, which it then uses to decrypt your secret.

### 4. AWS Secrets Manager
A service that helps you protect secrets needed to access your applications, services, and IT resources.
- **Integration:** Can be used to store API keys, DB credentials, and more.
- **Rotation:** Supports automated rotation using Lambda.

## Implementation Details
- **KMS Alias:** `alias/lab-key`
- **Encryption:** AES-256 (GCM)
- **Secret:** `lab/app/secure-api-key` encrypted with the CMK.

## SAA Exam Takeaways
- **KMS is Regional.** Keys cannot be moved between regions.
- **Key Policies are mandatory** for CMKs.
- **Secrets Manager vs. Parameter Store:** 
  - Secrets Manager: Supports rotation, higher cost, JSON support.
  - Parameter Store: No built-in rotation (requires custom Lambda), free for standard parameters.
- **Re-encryption:** Changing the KMS key for an existing resource (like RDS) usually requires a migration or snapshot/restore.
