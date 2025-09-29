#!/bin/bash

# 🎯 Zero-Downtime Infrastructure Updates - Interview Demo
# ========================================================
# This script demonstrates true infrastructure-level zero-downtime updates
# using EC2 + Auto Scaling Groups + CodeDeploy

echo "🚀 Welcome to the Zero-Downtime Infrastructure Update Demo"
echo "=========================================================="

# Set variables
ALB_URL="http://mercor-demo-alb-614078766.us-east-1.elb.amazonaws.com"
ASG_NAME="mercor-demo-ecs-asg"
CLUSTER_NAME="mercor-demo-cluster"

echo "📋 Current Infrastructure Status:"
echo "----------------------------------"

# Show Auto Scaling Group
echo "🏗️  Auto Scaling Group Status:"
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].{DesiredCapacity:DesiredCapacity,MinSize:MinSize,MaxSize:MaxSize,InstanceCount:length(Instances)}' \
  --output table

# Show CodeDeploy Applications
echo "🔄 CodeDeploy Configuration:"
aws deploy list-applications --output table
aws deploy list-deployment-groups --application-name mercor-demo-cd-app --output table

# Show ECS Cluster
echo "🐳 ECS Cluster Status:"
aws ecs describe-clusters --clusters $CLUSTER_NAME \
  --query 'clusters[0].{Status:status,ActiveServicesCount:activeServicesCount,RegisteredContainerInstancesCount:registeredContainerInstancesCount}' \
  --output table

echo ""
echo "🎯 KEY INTERVIEW POINTS:"
echo "========================"

echo "✅ ARCHITECTURE CHOICE:"
echo "   • EC2-based ECS (not Fargate) enables true infrastructure updates"
echo "   • Fargate is serverless - no AMIs, instance types, or host configs to update"
echo "   • EC2 + Auto Scaling Groups provide the infrastructure layer needed"

echo ""
echo "✅ ZERO-DOWNTIME MECHANISMS:"
echo "   • Auto Scaling Group instance refresh with 90% min healthy percentage"
echo "   • Rolling updates for AMI changes, instance type upgrades, capacity scaling"
echo "   • CodeDeploy provides blue/green deployment for application updates"

echo ""
echo "✅ INFRASTRUCTURE UPDATE CAPABILITIES:"
echo "   • AMI Updates: Latest ECS-optimized AMI rollouts"
echo "   • Instance Type Changes: t3.small → t3.medium → t3.large"
echo "   • Capacity Scaling: Horizontal scaling based on demand"
echo "   • Launch Template Updates: Security groups, user data, IAM roles"

echo ""
echo "🔧 DEMONSTRATION COMMANDS:"
echo "=========================="

echo "# 1. Infrastructure Scaling (2 → 4 instances):"
echo "aws autoscaling update-auto-scaling-group \\"
echo "  --auto-scaling-group-name $ASG_NAME \\"
echo "  --desired-capacity 4"

echo ""
echo "# 2. Instance Type Upgrade (t3.small → t3.medium):"
echo "# Update terraform/envs/dev/variables.tf:"
echo 'variable "instance_type" { default = "t3.medium" }'
echo "terraform apply -auto-approve"

echo ""
echo "# 3. Trigger Instance Refresh for Zero-Downtime Update:"
echo "aws autoscaling start-instance-refresh \\"
echo "  --auto-scaling-group-name $ASG_NAME \\"
echo "  --preferences MinHealthyPercentage=90,InstanceWarmup=60"

echo ""
echo "# 4. Monitor Instance Refresh Progress:"
echo "aws autoscaling describe-instance-refreshes \\"
echo "  --auto-scaling-group-name $ASG_NAME \\"
echo "  --query 'InstanceRefreshes[0].{Status:Status,PercentageComplete:PercentageComplete}'"

echo ""
echo "# 5. CodeDeploy Blue/Green Deployment:"
echo "aws deploy create-deployment \\"
echo "  --application-name mercor-demo-cd-app \\"
echo "  --deployment-group-name mercor-demo-dg \\"
echo "  --s3-location bucket=my-deployments,key=app.zip,bundleType=zip"

echo ""
echo "📚 TECHNICAL ARCHITECTURE:"
echo "=========================="

echo "🏗️  Terraform Modules (Infrastructure as Code):"
echo "   • network/    - VPC, subnets, security groups"
echo "   • compute/    - Auto Scaling Groups, launch templates, instance refresh"
echo "   • cluster/    - ECS cluster configuration"
echo "   • traffic/    - ALB, target groups for blue/green"
echo "   • ecs_service/- Task definitions, service configuration"
echo "   • codedeploy/ - Blue/green deployment automation"
echo "   • ecr/        - Container registry"

echo ""
echo "🔄 CI/CD Pipeline (GitHub Actions):"
echo "   • build.yml - Docker image building and ECR push"
echo "   • deploy.yml - Application deployment via ECS/CodeDeploy"
echo "   • infrastructure-update.yml - Zero-downtime infrastructure changes"

echo ""
echo "🎯 INTERVIEW SUCCESS FACTORS:"
echo "============================="

echo "✅ Problem Understanding:"
echo "   'Zero-downtime infrastructure updates require actual infrastructure'"
echo "   'Fargate abstracts away infrastructure - can't update what doesn't exist'"

echo ""
echo "✅ Solution Architecture:"
echo "   'EC2 + ASG provides the infrastructure layer for true updates'"
echo "   'Instance refresh maintains service availability during changes'"
echo "   'CodeDeploy handles application-level blue/green deployments'"

echo ""
echo "✅ Technical Deep Dive:"
echo "   'ASG rolling updates with health checks and warm-up periods'"
echo "   'Launch template versioning for infrastructure changes'"
echo "   'Integration with ECS for container orchestration'"

echo ""
echo "🏆 LIVE DEMO READY!"
echo "==================="
echo "Infrastructure: ✅ Deployed and operational"
echo "CodeDeploy: ✅ Configured for blue/green deployments"  
echo "Auto Scaling: ✅ Ready for zero-downtime updates"
echo "Terraform: ✅ Modular IaC with 7 components"
echo "CI/CD: ✅ GitHub Actions workflows configured"

echo ""
echo "🎤 You're ready to explain true zero-downtime infrastructure updates!"