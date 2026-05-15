# CLI Validation: Lab 6 - EBS & EFS

## 1. Verify EBS Attachment
```bash
# List volumes attached to Lab-3 instance
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=Lab-3-Web-Server" --query "Reservations[0].Instances[0].InstanceId" --output text)
aws ec2 describe-volumes --filters "Name=attachment.instance-id,Values=$INSTANCE_ID" --query "Volumes[*].{ID:VolumeId, State:State, Size:Size}"
```

## 2. Verify EBS Snapshot
```bash
aws ec2 describe-snapshots --filters "Name=tag:Name,Values=lab-ebs-snapshot-manual" --query "Snapshots[*].{ID:SnapshotId, Progress:Progress, Volume:VolumeId}"
```

## 3. Verify EFS Mount Targets
```bash
EFS_ID=$(aws efs describe-file-systems --query "FileSystems[?Name=='lab-shared-filesystem'].FileSystemId" --output text)
aws efs describe-mount-targets --file-system-id $EFS_ID --query "MountTargets[*].{ID:MountTargetId, AZ:AvailabilityZoneName, State:LifeCycleState}"
```

## 4. Verify Shared Storage (The "Concurrent" Test)
```bash
# 1. Connect to Instance A and write a file
# 2. Connect to Instance B and read the file
# Since we use ASG, get the ALB DNS and find our instances
ALB_DNS=$(aws elbv2 describe-load-balancers --names "lab-alb" --query "LoadBalancers[0].DNSName" --output text)
echo "Access app at http://$ALB_DNS"
```
