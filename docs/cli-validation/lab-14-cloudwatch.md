# CLI Validation: Lab 14 - CloudWatch

## 1. Verify Alarms Status
```bash
# List all alarms and their current states (OK, ALARM, INSUFFICIENT_DATA)
aws cloudwatch describe-alarms --query "MetricAlarms[*].{Name:AlarmName, State:StateValue, Metric:MetricName}"
```

## 2. Verify Dashboard Configuration
```bash
# Check if the dashboard exists and view its body
aws cloudwatch get-dashboard --dashboard-name "Lab-Architecture-Overview" --query "DashboardBody" --output text | jq .
```

## 3. Verify Log Groups
```bash
# List the custom log group and its retention settings
aws logs describe-log-groups --log-group-name-prefix "/aws/app/lab-custom-events" --query "logGroups[*].{Name:logGroupName, Retention:retentionInDays}"
```

## 4. Simulate a Metric Spike (Conceptual)
You can manually "force" an alarm state via the CLI to test notifications:
```bash
# ALARM NAME should match your terraform output
aws cloudwatch set-alarm-state \
    --alarm-name "lab-asg-high-cpu" \
    --state-value ALARM \
    --state-reason "Manual testing of SNS integration"

# Check your email for the SNS notification!
# Don't forget to set it back to OK:
aws cloudwatch set-alarm-state \
    --alarm-name "lab-asg-high-cpu" \
    --state-value OK \
    --state-reason "Test complete"
```
