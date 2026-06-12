# CLI Validation: Lab 16 - KMS & Secrets Manager

## 1. Verify KMS Key Status
```bash
# Get the key metadata
aws kms describe-key --key-id "alias/lab-key" --query "KeyMetadata.{ARN:Arn, State:KeyState, Rotation:EncryptionAlgorithms}"
```

## 2. Verify Key Policy
```bash
# List the policy names for the key
aws kms list-key-policies --key-id "alias/lab-key"

# Read the Default policy
aws kms get-key-policy --key-id "alias/lab-key" --policy-name "default" --output text | jq .
```

## 3. Verify Secrets Manager Encryption
```bash
# Check which KMS key the secret is using
aws secretsmanager describe-secret --secret-id "lab/app/secure-api-key" --query "KmsKeyId"
```

## 4. Test Secret Retrieval
```bash
# Retrieve and decrypt the secret
aws secretsmanager get-secret-value --secret-id "lab/app/secure-api-key" --query "SecretString" --output text | jq .
```

## 5. Test Access Denied (Conceptual)
If you create a temporary IAM role that has `secretsmanager:GetSecretValue` permission but IS NOT in the **KMS Key Policy**, the retrieval will fail with a `KMS AccessDenied` error. This is a common SAA scenario.
```bash
# SAA Architect Challenge: 
# Try assuming a different role and fetching this secret. 
# You will see that SM permissions are not enough; KMS permissions are also required!
```
