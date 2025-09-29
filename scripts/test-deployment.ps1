# Test CodeDeploy Blue/Green Deployment Script
# This script demonstrates the deployment process for the interview

Write-Host "=== ECS CodeDeploy Blue/Green Deployment Test ===" -ForegroundColor Cyan
Write-Host ""

# Check current cluster status
Write-Host "1. Checking ECS Cluster Status..." -ForegroundColor Yellow
$clusterInfo = aws ecs describe-clusters --clusters mercor-demo-cluster --region us-east-1 --include STATISTICS | ConvertFrom-Json
$runningTasks = $clusterInfo.clusters[0].runningTasksCount
$pendingTasks = $clusterInfo.clusters[0].pendingTasksCount
$activeServices = $clusterInfo.clusters[0].activeServicesCount
$registeredInstances = $clusterInfo.clusters[0].registeredContainerInstancesCount

Write-Host "   - Registered Container Instances: $registeredInstances" -ForegroundColor White
Write-Host "   - Running Tasks: $runningTasks" -ForegroundColor White
Write-Host "   - Pending Tasks: $pendingTasks" -ForegroundColor White
Write-Host "   - Active Services: $activeServices" -ForegroundColor White
Write-Host ""

# Check Auto Scaling Group status
Write-Host "2. Checking Auto Scaling Group Status..." -ForegroundColor Yellow
$asgInfo = aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names mercor-demo-ecs-asg --region us-east-1 | ConvertFrom-Json
$desiredCapacity = $asgInfo.AutoScalingGroups[0].DesiredCapacity
$instanceCount = $asgInfo.AutoScalingGroups[0].Instances.Count
$healthyInstances = ($asgInfo.AutoScalingGroups[0].Instances | Where-Object { $_.HealthStatus -eq "Healthy" }).Count

Write-Host "   - Desired Capacity: $desiredCapacity" -ForegroundColor White
Write-Host "   - Current Instances: $instanceCount" -ForegroundColor White
Write-Host "   - Healthy Instances: $healthyInstances" -ForegroundColor White
Write-Host ""

# Check instance refresh status
Write-Host "3. Checking Instance Refresh Status..." -ForegroundColor Yellow
$refreshInfo = aws autoscaling describe-instance-refreshes --auto-scaling-group-name mercor-demo-ecs-asg --region us-east-1 | ConvertFrom-Json
$latestRefresh = $refreshInfo.InstanceRefreshes[0]
$refreshStatus = $latestRefresh.Status
$refreshPercent = $latestRefresh.PercentageComplete

Write-Host "   - Refresh Status: $refreshStatus" -ForegroundColor White
Write-Host "   - Progress: $refreshPercent%" -ForegroundColor White
Write-Host ""

# Check CodeDeploy application status
Write-Host "4. Checking CodeDeploy Application..." -ForegroundColor Yellow
$deployments = aws deploy list-deployments --application-name mercor-demo-cd-app --region us-east-1 | ConvertFrom-Json
$deploymentCount = $deployments.deployments.Count

Write-Host "   - Total Deployments: $deploymentCount" -ForegroundColor White

if ($deploymentCount -gt 0) {
    $latestDeploymentId = $deployments.deployments[0]
    $deploymentInfo = aws deploy get-deployment --deployment-id $latestDeploymentId --region us-east-1 | ConvertFrom-Json
    $deploymentStatus = $deploymentInfo.deploymentInfo.status
    Write-Host "   - Latest Deployment Status: $deploymentStatus" -ForegroundColor White
}
Write-Host ""

# Provide next steps based on current status
Write-Host "5. Next Steps:" -ForegroundColor Green
if ($registeredInstances -eq 0) {
    Write-Host "   - Waiting for ECS instances to register with cluster" -ForegroundColor Yellow
    Write-Host "   - Current instance refresh will apply improved user data script" -ForegroundColor Yellow
    Write-Host "   - This demonstrates zero-downtime infrastructure updates!" -ForegroundColor Green
} elseif ($runningTasks -eq 0) {
    Write-Host "   - Ready to create CodeDeploy deployment!" -ForegroundColor Green
    Write-Host "   - Run: aws deploy create-deployment --application-name mercor-demo-cd-app" -ForegroundColor Cyan
} else {
    Write-Host "   - System is healthy and running!" -ForegroundColor Green
    Write-Host "   - Access application at: http://mercor-demo-alb-614078766.us-east-1.elb.amazonaws.com" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Interview Key Points:" -ForegroundColor Magenta
Write-Host "   - Infrastructure updates via ASG instance refresh (zero downtime)" -ForegroundColor White
Write-Host "   - Blue/green deployments via CodeDeploy" -ForegroundColor White
Write-Host "   - ECS on EC2 enables true infrastructure management" -ForegroundColor White
Write-Host "   - Terraform IaC with 7 modular components" -ForegroundColor White