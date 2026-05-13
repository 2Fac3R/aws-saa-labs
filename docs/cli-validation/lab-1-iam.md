# CLI Validation: Lab 1 - IAM & EC2

## 1. Verify IAM Role & Policy
```bash
ROLE_NAME="ec2-s3-access-role"

# Check Trust Relationship (Should allow ec2.amazonaws.com)
aws iam get-role --role-name $ROLE_NAME --query "Role.AssumeRolePolicyDocument.Statement[0].Principal.Service"

# List Attached Policies
aws iam list-attached-role-policies --role-name $ROLE_NAME --query "AttachedPolicies[*].PolicyName"
```

## 2. Verify EC2 Instance Profile
```bash
# Check if the Instance Profile is linked to the Role
aws iam get-instance-profile --instance-profile-name ec2-s3-access-profile --query "InstanceProfile.Roles[0].RoleName"
```

## 3. Verify SSM Connectivity
If the instance is configured correctly, it should appear in the SSM managed list.
```bash
aws ssm describe-instance-information --query "InstanceInformationList[*].{ID:InstanceId, Ping:PingStatus, OS:PlatformName}"
```
