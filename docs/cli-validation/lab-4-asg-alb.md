# CLI Validation: Lab 4 - ALB & ASG

## 1. Verify ALB Status
```bash
# Get the ALB DNS Name
ALB_DNS=$(aws elbv2 describe-load-balancers --names "lab-alb" --query "LoadBalancers[0].DNSName" --output text)

# Verify ALB State
aws elbv2 describe-load-balancers --names "lab-alb" --query "LoadBalancers[0].State.Code"
```

## 2. Verify Target Group Health
Wait a few minutes after deployment for the health checks to pass.
```bash
TG_ARN=$(aws elbv2 describe-target-groups --names "lab-web-tg" --query "TargetGroups[0].TargetGroupArn" --output text)

# Check health of targets (Should show 'healthy')
aws elbv2 describe-target-health --target-group-arn $TG_ARN --query "TargetHealthDescriptions[*].{ID:Target.Id, Health:TargetHealth.State}"
```

## 3. Verify ASG Instances
```bash
# List instances managed by the ASG
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "lab-web-asg" --query "AutoScalingGroups[0].Instances[*].{ID:InstanceId, AZ:AvailabilityZone, Health:HealthStatus}"
```

## 4. Test High Availability
```bash
# Access the app via the Load Balancer
curl -s "http://$ALB_DNS/" | jq .

# Note: You should see different hostnames as you refresh (if the ALB is balancing)
for i in {1..5}; do curl -s "http://$ALB_DNS/" | jq .hostname; done
```

## 5. Simulate Failure (Architect Level)
```bash
# Terminate one instance and watch the ASG replace it
INSTANCE_TO_KILL=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "lab-web-asg" --query "AutoScalingGroups[0].Instances[0].InstanceId" --output text)

aws ec2 terminate-instances --instance-ids $INSTANCE_TO_KILL
```
