# CLI Validation: Lab 7 - RDS & Secrets Manager

## 1. Verify RDS Instance Status
```bash
# Check if instance is 'available' and Multi-AZ is 'true'
aws rds describe-db-instances --db-instance-identifier "lab-db-instance" --query "DBInstances[0].{Status:DBInstanceStatus, MultiAZ:MultiAZ, Endpoint:Endpoint.Address}"
```

## 2. Verify DB Subnet Group
```bash
# Ensure it spans at least two AZs
aws rds describe-db-subnet-groups --db-subnet-group-name "lab-db-subnet-group" --query "DBSubnetGroups[0].Subnets[*].{Subnet:SubnetIdentifier, AZ:SubnetAvailabilityZone.Name}"
```

## 3. Verify Secrets Manager Integration
```bash
# Get the secret value (Requires IAM permission)
SECRET_ARN=$(aws secretsmanager list-secrets --filters "Key=name,Values=lab/rds/postgresql-credentials" --query "SecretList[0].ARN" --output text)

aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --query "SecretString" --output text | jq .
```

## 4. Test Connectivity (Conceptual)
Since the RDS is in a private subnet and only allows traffic from the VPC, you would normally test this from an EC2 instance within the VPC:
```bash
# From an EC2 in the VPC:
# psql -h <RDS_ENDPOINT> -U dbadmin -d labdb
```
