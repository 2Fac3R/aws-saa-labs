# CLI Validation: Lab 10 - ECS & CI/CD

## 1. Verify Load Balancer & Health
```bash
# Get the ALB DNS Name
ALB_DNS=$(aws elbv2 describe-load-balancers --names "lab-ecs-alb" --query "LoadBalancers[0].DNSName" --output text)
echo "Access app at: http://$ALB_DNS"

# Check Target Group Health (Should show 'healthy')
TG_ARN=$(aws elbv2 describe-target-groups --names "lab-ecs-tg" --query "TargetGroups[0].TargetGroupArn" --output text)
aws elbv2 describe-target-health --target-group-arn $TG_ARN --query "TargetHealthDescriptions[*].{ID:Target.Id, Health:TargetHealth.State}"
```

## 2. Verify OIDC & IAM Roles
```bash
# Verify the specialized roles exist
aws iam list-roles --query "Roles[?contains(RoleName, 'engineering-mastery')].RoleName"

# Verify OIDC Provider
aws iam list-open-id-connect-providers
```

## 3. Verify ECR Repository
```bash
aws ecr describe-repositories --repository-names "engineering-mastery-lab" --query "repositories[0].repositoryUri"
```

## 4. Verify ECS Service Deployment
```bash
# Check if the service is active and linked to the ALB
aws ecs describe-services \
    --cluster "engineering-mastery-cluster" \
    --services "mastery-lab-service" \
    --query "services[0].{Status:status, ALB:loadBalancers[0].targetGroupArn}"
```

## 5. View Container Logs (CLI)
```bash
# Get latest log streams from CloudWatch
aws logs describe-log-streams \
    --log-group-name "/ecs/engineering-mastery-lab" \
    --order-by "LastEventTime" \
    --descending \
    --limit 1 \
    --query "logStreams[0].logStreamName"
```
