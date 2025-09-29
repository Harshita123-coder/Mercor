# ECS Infrastructure Update System - Interview Documentation

## 🎯 Project Overview
A production-ready ECS deployment pipeline demonstrating zero-downtime infrastructure updates using AWS CodeDeploy, Terraform IaC, and GitHub Actions CI/CD.

## 🏗️ Architecture Highlights

### Key Design Decision: EC2 vs Fargate
- **Chosen**: EC2-based ECS with Auto Scaling Groups
- **Why**: Fargate is serverless and cannot demonstrate infrastructure updates (no AMIs, instance types to update)
- **Benefit**: Enables true infrastructure-level changes (AMI updates, instance type changes, security configurations)

### Core Components
1. **ECS Cluster**: Container orchestration on EC2 instances
2. **Auto Scaling Group**: Zero-downtime infrastructure updates with 90% minimum healthy capacity
3. **CodeDeploy**: Blue/green application deployments with automatic rollback
4. **Application Load Balancer**: Traffic management with blue/green target groups
5. **Terraform**: Infrastructure as Code with 7 modular components
6. **GitHub Actions**: Automated CI/CD for both application and infrastructure

## 📁 Project Structure
```
├── terraform/
│   ├── modules/
│   │   ├── network/           # VPC, subnets, routing
│   │   ├── ecr/              # Container registry
│   │   ├── cluster/          # ECS cluster configuration
│   │   ├── compute/          # ASG, launch templates, EC2
│   │   ├── traffic/          # ALB, target groups, security
│   │   ├── ecs_service/      # ECS service with CODE_DEPLOY
│   │   └── codedeploy/       # Blue/green deployment config
│   └── envs/dev/             # Environment-specific configs
├── .github/workflows/
│   ├── build.yml             # Docker build and ECR push
│   ├── deploy.yml            # CodeDeploy application deployment
│   └── infrastructure-update.yml  # Zero-downtime infrastructure changes
├── app/
│   ├── server.py             # Python web application
│   └── Dockerfile            # Container configuration
└── codedeploy/
    ├── appspec.yaml          # CodeDeploy deployment specification
    └── taskdef.template.json # ECS task definition template
```

## 🚀 Infrastructure Update Capabilities

### 1. Auto Scaling Group Instance Refresh
- **Zero-downtime AMI updates**: Deploy new ECS-optimized AMIs
- **Instance type changes**: Upgrade/downgrade instance types without service interruption
- **Configuration updates**: Launch template changes (user data, security groups)
- **Health preservation**: 90% minimum healthy capacity ensures continuous service

### 2. Blue/Green Application Deployments
- **CodeDeploy integration**: Automated deployment with ECS CODE_DEPLOY controller
- **Traffic shifting**: Gradual traffic migration between blue/green target groups
- **Automatic rollback**: Failed deployments automatically revert to stable version
- **Health monitoring**: Continuous health checks during deployment process

## 🔧 Technical Implementation Details

### Terraform Modules (Infrastructure as Code)
1. **Network Module**: VPC with public subnets across multiple AZs
2. **ECR Module**: Private container registry for Docker images
3. **Cluster Module**: ECS cluster with capacity providers
4. **Compute Module**: Auto Scaling Group with EC2 instances
5. **Traffic Module**: Application Load Balancer with blue/green target groups
6. **ECS Service Module**: ECS service configured for CODE_DEPLOY controller
7. **CodeDeploy Module**: Application and deployment group for blue/green deployments

### GitHub Actions Workflows
1. **Build Workflow**: Builds Docker image and pushes to ECR on code changes
2. **Deploy Workflow**: Creates CodeDeploy deployment for blue/green application updates
3. **Infrastructure Update Workflow**: Demonstrates zero-downtime infrastructure changes

### Key Configuration Files
- **appspec.yaml**: CodeDeploy deployment hooks and lifecycle management
- **taskdef.template.json**: ECS task definition with dynamic port mapping
- **launch template**: EC2 configuration with ECS agent bootstrap

## 🎤 Interview Talking Points

### 1. Architecture Deep Dive
- **"Why did you choose EC2 over Fargate?"**
  - Fargate is serverless - no infrastructure to update
  - EC2 enables AMI updates, instance type changes, security configurations
  - Auto Scaling Groups provide instance refresh capabilities

### 2. Zero-Downtime Strategy
- **Auto Scaling Group Instance Refresh**: 90% minimum healthy capacity
- **Rolling updates**: Gradual replacement of instances
- **Health checks**: ECS and ALB health monitoring
- **Rollback capability**: Automatic reversion on failure

### 3. CI/CD Pipeline
- **Infrastructure updates**: Terraform apply with instance refresh
- **Application deployments**: CodeDeploy blue/green with traffic shifting
- **Monitoring**: CloudWatch logs and ALB health checks
- **Automation**: GitHub Actions triggers on code changes

### 4. Scalability & Reliability
- **Multi-AZ deployment**: High availability across availability zones
- **Auto Scaling**: Dynamic capacity based on demand
- **Load balancing**: Traffic distribution and health monitoring
- **Container orchestration**: ECS manages container lifecycle

## 📊 Live System Access
- **Application URL**: http://mercor-demo-alb-614078766.us-east-1.elb.amazonaws.com
- **GitHub Repository**: https://github.com/Harshita123-coder/Mercor
- **AWS Region**: us-east-1
- **ECS Cluster**: mercor-demo-cluster
- **CodeDeploy Application**: mercor-demo-cd-app

## 🔍 Demonstration Scenarios

### Scenario 1: Infrastructure Update
```bash
# Update AMI in launch template
terraform apply -auto-approve
# Triggers ASG instance refresh with zero downtime
```

### Scenario 2: Application Deployment
```bash
# Push code changes
git push origin main
# Triggers GitHub Actions → Docker build → CodeDeploy → Blue/Green deployment
```

### Scenario 3: Rollback
- Failed deployments automatically rollback via CodeDeploy
- Infrastructure changes can be reverted via Terraform state

## 💡 Advanced Features
- **Infrastructure as Code**: Version-controlled, repeatable infrastructure
- **Modular design**: Reusable Terraform modules
- **Security**: IAM roles, security groups, private networking
- **Monitoring**: CloudWatch integration for logs and metrics
- **Cost optimization**: Auto Scaling based on demand

This system demonstrates enterprise-level DevOps practices combining infrastructure management, application deployment, and operational excellence.