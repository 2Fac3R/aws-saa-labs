# CLI Validation: Lab 2 - VPC Foundations

## 1. Verify VPC & Subnets
```bash
# Get VPC ID by Name
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=lab-vpc" --query "Vpcs[0].VpcId" --output text)

# List Subnets and their Public IP settings
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].{ID:SubnetId, CIDR:CidrBlock, Public:MapPublicIpOnLaunch, AZ:AvailabilityZone}" --output table
```

## 2. Verify Route Tables (The "Magic" of Public vs Private)
```bash
# Find the Route Table that has an IGW (Public)
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[*].{ID:RouteTableId, Gateway:Routes[?GatewayId != 'local'].GatewayId}"
```

## 3. Verify S3 Gateway Endpoint
```bash
# Check for the S3 Prefix List in the Route Table
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$VPC_ID" --query "VpcEndpoints[*].{Service:ServiceName, Type:VpcEndpointType, State:State}"
```
