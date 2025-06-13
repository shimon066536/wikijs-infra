#!/bin/bash

echo "Checking for Terraform files..."
if [ ! -f "main.tf" ]; then
  echo "main.tf not found. Please run from the project root."
  exit 1
fi

#  Terraform destroy
echo "Running terraform destroy..."
terraform destroy -var-file="terraform.tfvars" -auto-approve

#  Create report file
REPORT_FILE="aws_remaining_resources_report.txt"
echo "Creating remaining AWS resources report in: $REPORT_FILE"
echo "AWS Remaining Resources Report (after terraform destroy)" > $REPORT_FILE
echo "Generated at: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

REGION="eu-west-1" change if needed

### ALB
echo "Load Balancers (ALB):" | tee -a $REPORT_FILE
aws elbv2 describe-load-balancers --region $REGION --query "LoadBalancers[*].{DNS:DNSName,Name:LoadBalancerName}" --output table | tee -a $REPORT_FILE
echo "" >> $REPORT_FILE

### Target Groups
echo "Target Groups:" | tee -a $REPORT_FILE
aws elbv2 describe-target-groups --region $REGION --query "TargetGroups[*].{Name:TargetGroupName,ARN:TargetGroupArn}" --output table | tee -a $REPORT_FILE
echo "" >> $REPORT_FILE

### ECS Clusters
echo "ECS Clusters:" | tee -a $REPORT_FILE
aws ecs list-clusters --region $REGION --output table | tee -a $REPORT_FILE
echo "" >> $REPORT_FILE

### RDS Instances
echo "RDS Instances:" | tee -a $REPORT_FILE
aws rds describe-db-instances --region $REGION --query "DBInstances[*].{ID:DBInstanceIdentifier,Status:DBInstanceStatus}" --output table | tee -a $REPORT_FILE
echo "" >> $REPORT_FILE

### Secrets
echo "Secrets Manager:" | tee -a $REPORT_FILE
aws secretsmanager list-secrets --region $REGION --query "SecretList[*].Name" --output table | tee -a $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Report generated successfully: $REPORT_FILE"
