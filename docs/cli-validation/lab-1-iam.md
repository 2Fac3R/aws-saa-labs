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

## 4. Run Automated Validation
Since the script is now automatically downloaded via User Data, you can run it directly through SSM:
```bash
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=Lab-1-IAM-EC2" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].InstanceId" --output text)
BUCKET_NAME=$(aws s3 ls | grep aws-saa-labs-data | cut -d' ' -f3)

aws ssm send-command \
    --instance-ids "$INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --parameters "commands=[\"python3 /home/ec2-user/scripts/s3_check.py \$BUCKET_NAME\"]" \
    --query "Command.CommandId"
```
