# CLI Validation: Lab 3 - EC2 & Compute

## 1. Verify Launch Template
```bash
# List Launch Templates
aws ec2 describe-launch-templates --query "LaunchTemplates[*].{Name:LaunchTemplateName, ID:LaunchTemplateId}"

# View UserData (encoded in base64)
LT_ID=$(aws ec2 describe-launch-templates --launch-template-names "lab-web-lt" --query "LaunchTemplates[0].LaunchTemplateId" --output text 2>/dev/null || echo "Check LT Name")
aws ec2 describe-launch-template-versions --launch-template-id $LT_ID --versions "$Latest" --query "LaunchTemplateVersions[0].LaunchTemplateData.UserData"
```

## 2. Verify Elastic IP
```bash
# List all EIPs and their associated Instance IDs
aws ec2 describe-addresses --query "Addresses[*].{IP:PublicIp, Instance:InstanceId, Domain:Domain}"
```

## 3. Verify Security Group Rules
```bash
# Check Inbound Rules for Port 80
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=lab-web-sg" --query "SecurityGroups[0].GroupId" --output text)
aws ec2 describe-security-groups --group-ids $SG_ID --query "SecurityGroups[0].IpPermissions[?ToPort==`80`]"
```

## 4. Test Web Server Response
```bash
# Get the EIP from outputs and curl it
PUBLIC_IP=$(aws ec2 describe-addresses --filters "Name=tag:Name,Values=lab-web-eip" --query "Addresses[0].PublicIp" --output text)
curl -s "http://$PUBLIC_IP/" | jq .
```
