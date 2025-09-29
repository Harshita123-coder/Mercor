#!/bin/bash
# Create CodeDeploy Deployment Script

echo "=== Creating CodeDeploy Deployment ===" 
echo ""

# Get the latest task definition revision
TASK_DEF_ARN=$(aws ecs describe-task-definition --task-definition mercor-demo-task --region us-east-1 --query 'taskDefinition.taskDefinitionArn' --output text)
echo "Using task definition: $TASK_DEF_ARN"

# Create the task definition file for CodeDeploy
cat > /tmp/taskdef.json << EOF
{
  "family": "mercor-demo-task",
  "taskRoleArn": "arn:aws:iam::533567530547:role/mercor-demo-task-exec",
  "executionRoleArn": "arn:aws:iam::533567530547:role/mercor-demo-task-exec",
  "networkMode": "bridge",
  "requiresCompatibilities": ["EC2"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "app",
      "image": "533567530547.dkr.ecr.us-east-1.amazonaws.com/mercor-ecs-demo:latest",
      "memory": 512,
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/mercor-demo",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
EOF

# Create the appspec file for CodeDeploy
cat > /tmp/appspec.yaml << EOF
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: <TASK_DEFINITION>
        LoadBalancerInfo:
          ContainerName: app
          ContainerPort: 8080
        PlatformVersion: LATEST
Hooks:
  - BeforeInstall:
      - location: "scripts/stop_application.sh"
        timeout: 60
        runas: root
  - ApplicationStart:
      - location: "scripts/start_application.sh"
        timeout: 60
        runas: root
  - ApplicationStop:
      - location: "scripts/stop_application.sh"
        timeout: 60
        runas: root
EOF

# Create the deployment
echo ""
echo "Creating CodeDeploy deployment..."

aws deploy create-deployment \
  --application-name mercor-demo-cd-app \
  --deployment-group-name mercor-demo-dg \
  --revision revisionType=S3,s3Location='{bucket=your-bucket,key=your-key,bundleType=zip}' \
  --region us-east-1

echo ""
echo "Deployment created! Check AWS Console for status."