# ECS Blue/Green Deployment with Zero-Downtime Infrastructure Updates

## 🎯 Overview

This repository implements a production-ready ECS deployment pipeline with:
- **Blue/Green Application Deployments** using AWS CodeDeploy
- **Zero-Downtime Infrastructure Updates** using Auto Scaling Group Instance Refresh
- **Complete Infrastructure as Code** using Terraform modules
- **Automated CI/CD** using GitHub Actions

## 🏗️ Architecture

### High-Level Architecture
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub        │    │   AWS CodeDeploy │    │   ECS Cluster   │
│   Actions       │───▶│   Blue/Green     │───▶│   EC2 Instances │
│   CI/CD         │    │   Deployment     │    │   Auto Scaling  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │   Application    │    │   Infrastructure│
                       │   Load Balancer  │    │   Instance      │
                       │   Blue/Green TGs │    │   Refresh       │
                       └──────────────────┘    └─────────────────┘
```

### Component Breakdown

#### 🌐 **Network Layer** (`modules/network/`)
- VPC with public subnets across multiple AZs
- Internet Gateway and routing tables
- Foundation for all other resources

#### 📦 **Container Registry** (`modules/ecr/`)
- Elastic Container Registry for Docker images
- Image scanning and lifecycle policies
- Secure image storage and versioning

#### ⚖️ **Load Balancing** (`modules/traffic/`)
- Application Load Balancer with security groups
- **Blue and Green target groups** for zero-downtime deployments
- Health checks and traffic routing rules

#### 🖥️ **Compute Layer** (`modules/compute/`)
- **Auto Scaling Group** with EC2 instances
- **Instance Refresh** for zero-downtime infrastructure updates
- ECS-optimized AMIs with capacity providers
- Proper IAM roles and security groups

#### ⚡ **Container Orchestration** (`modules/cluster/` & `modules/ecs_service/`)
- ECS Cluster with container insights
- Task definitions with logging configuration
- ECS Service controlled by CodeDeploy

#### 🔄 **Deployment Pipeline** (`modules/codedeploy/`)
- CodeDeploy application and deployment group
- Blue/Green deployment configuration
- Automated rollback on failure

## 🚀 Zero-Downtime Deployments

### 1. Application Updates (Blue/Green)
**Process:**
1. New task definition is registered with updated image
2. CodeDeploy creates new task set in Green target group
3. Health checks ensure Green tasks are ready
4. Traffic is gradually shifted from Blue to Green
5. Blue tasks are terminated after successful deployment

### 2. Infrastructure Updates (Instance Refresh)
**Process:**
1. Terraform updates launch template (new AMI, instance type, etc.)
2. Auto Scaling Group triggers Instance Refresh automatically
3. New instances are launched with updated configuration
4. ECS tasks are drained from old instances
5. Old instances are terminated maintaining minimum healthy percentage

## 🛠️ Technology Stack

- **Infrastructure**: Terraform (modular design)
- **Container Orchestration**: Amazon ECS on EC2
- **Load Balancing**: Application Load Balancer
- **Deployments**: AWS CodeDeploy (Blue/Green)
- **CI/CD**: GitHub Actions
- **Container Registry**: Amazon ECR
- **Monitoring**: CloudWatch Logs & Container Insights

## 📁 Repository Structure

```
mercor-ecs-bluegreen/
├── app/                    # Sample application
│   ├── Dockerfile         
│   └── server.py          
├── codedeploy/            # CodeDeploy configuration
│   ├── appspec.yaml       
│   └── taskdef.template.json
├── terraform/
│   ├── envs/dev/          # Environment-specific config
│   │   ├── main.tf        # Module orchestration
│   │   ├── variables.tf   
│   │   └── terraform.tfvars
│   └── modules/           # Reusable Terraform modules
│       ├── network/       # VPC, subnets, routing
│       ├── ecr/           # Container registry
│       ├── traffic/       # ALB, target groups
│       ├── cluster/       # ECS cluster
│       ├── compute/       # ASG, launch template
│       ├── ecs_service/   # Task definition, service
│       └── codedeploy/    # Deployment pipeline
└── .github/workflows/     # CI/CD pipelines
    ├── build.yml         # Build and push images
    └── deploy.yml        # Infrastructure and app deployment
```

## 🚀 Getting Started

### Prerequisites
1. AWS Account with programmatic access
2. GitHub repository with secrets configured:
   - `AWS_REGION`
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY` 
   - `ECR_REPOSITORY` (set to `mercor-ecs-demo`)

### Deployment Steps

1. **Initial Infrastructure Deployment**
   ```bash
   cd terraform/envs/dev
   terraform init
   terraform apply
   ```

2. **Application Deployment**
   - Push code changes to trigger GitHub Actions
   - Monitor deployment in AWS CodeDeploy console

3. **Infrastructure Updates**
   - Modify variables in `terraform.tfvars` (e.g., instance_type)
   - Commit changes to trigger automated deployment
   - Zero downtime maintained through Instance Refresh

## 📊 Key Features

### ✅ **Production Ready**
- Multi-AZ deployment for high availability
- Proper security groups and IAM roles
- Container insights and logging
- Resource tagging and lifecycle management

### ✅ **Zero Downtime**
- **Application**: Blue/Green deployments with health checks
- **Infrastructure**: Rolling Instance Refresh with min healthy percentage
- **Automated**: No manual intervention required

### ✅ **Cost Optimized**
- Auto Scaling based on demand
- Spot instance support capability
- ECR lifecycle policies for image cleanup

### ✅ **Security First**
- Least privilege IAM roles
- Private subnets for compute resources
- Security groups with minimal required access
- Container image scanning

## 🎥 Demo Video

[Insert Loom video link here demonstrating:]
- Initial deployment
- Blue/Green application update
- Infrastructure update (instance type change)
- Zero downtime verification during both scenarios

## 🔧 Configuration

Key configuration files:
- `terraform/envs/dev/terraform.tfvars` - Environment variables
- `codedeploy/appspec.yaml` - Deployment specification
- `.github/workflows/` - CI/CD pipeline configuration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.