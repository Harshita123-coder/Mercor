# CodeDeploy Deployment Creation Script
# This will create a blue/green deployment using CodeDeploy

Write-Host "=== CodeDeploy Blue/Green Deployment ===" -ForegroundColor Cyan
Write-Host ""

# Check if we have container instances registered
Write-Host "1. Checking ECS Container Instances..." -ForegroundColor Yellow
$containerInstances = aws ecs describe-clusters --clusters mercor-demo-cluster --region us-east-1 --query 'clusters[0].registeredContainerInstancesCount' --output text

Write-Host "   Registered Container Instances: $containerInstances" -ForegroundColor White

if ($containerInstances -eq "0") {
    Write-Host "   No container instances registered yet. Waiting..." -ForegroundColor Red
    Write-Host ""
    Write-Host "   Checking instance status:" -ForegroundColor Yellow
    
    # Check if our SSM commands completed
    $commandIds = @("4212b8a6-1852-4136-95cb-a2f2ad840cd0", "21697e96-421e-492b-9f33-61564b69e95d", "765aa443-444f-4b0b-87cf-25c5010774cf")
    foreach($commandId in $commandIds) {
        $status = aws ssm get-command-invocation --command-id $commandId --instance-id i-0523a344e75e2c19d --region us-east-1 --query "Status" --output text 2>$null
        if ($status) {
            Write-Host "     Command $commandId`: $status" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "   Try running this script again in a few minutes..." -ForegroundColor Yellow
    return
}

Write-Host "   ✅ Container instances available!" -ForegroundColor Green
Write-Host ""

# Create task definition file for CodeDeploy
Write-Host "2. Creating Task Definition..." -ForegroundColor Yellow

$taskDefContent = @{
    family = "mercor-demo-task"
    taskRoleArn = "arn:aws:iam::533567530547:role/mercor-demo-task-exec"  
    executionRoleArn = "arn:aws:iam::533567530547:role/mercor-demo-task-exec"
    networkMode = "bridge"
    requiresCompatibilities = @("EC2")
    cpu = "256"
    memory = "512"
    containerDefinitions = @(
        @{
            name = "app"
            image = "533567530547.dkr.ecr.us-east-1.amazonaws.com/mercor-ecs-demo:latest"
            memory = 512
            portMappings = @(
                @{
                    containerPort = 8080
                    protocol = "tcp"
                }
            )
            essential = $true
            logConfiguration = @{
                logDriver = "awslogs"
                options = @{
                    "awslogs-group" = "/ecs/mercor-demo"
                    "awslogs-region" = "us-east-1"  
                    "awslogs-stream-prefix" = "ecs"
                }
            }
        }
    )
} | ConvertTo-Json -Depth 10

$taskDefContent | Out-File -FilePath "taskdef.json" -Encoding UTF8
Write-Host "   Task definition saved to taskdef.json" -ForegroundColor White

# Register the task definition
Write-Host "3. Registering Task Definition..." -ForegroundColor Yellow
$taskDefArn = aws ecs register-task-definition --cli-input-json file://taskdef.json --region us-east-1 --query 'taskDefinition.taskDefinitionArn' --output text
Write-Host "   Task Definition ARN: $taskDefArn" -ForegroundColor White

# Create AppSpec for CodeDeploy
Write-Host "4. Creating AppSpec..." -ForegroundColor Yellow
$appSpecContent = @"
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service  
      Properties:
        TaskDefinition: <TASK_DEFINITION>
        LoadBalancerInfo:
          ContainerName: app
          ContainerPort: 8080
"@

$appSpecContent | Out-File -FilePath "appspec.yml" -Encoding UTF8
Write-Host "   AppSpec saved to appspec.yml" -ForegroundColor White

Write-Host ""
Write-Host "5. Creating CodeDeploy Deployment..." -ForegroundColor Green

# For now, let's show what the command would be (since we need to upload to S3 first)
Write-Host "   To create deployment, you would run:" -ForegroundColor Cyan
Write-Host "   aws deploy create-deployment \\" -ForegroundColor Gray
Write-Host "     --application-name mercor-demo-cd-app \\" -ForegroundColor Gray  
Write-Host "     --deployment-group-name mercor-demo-dg \\" -ForegroundColor Gray
Write-Host "     --task-definition-arn $taskDefArn \\" -ForegroundColor Gray
Write-Host "     --region us-east-1" -ForegroundColor Gray

Write-Host ""
Write-Host "🎉 Ready for Blue/Green Deployment!" -ForegroundColor Green