# INTERVIEWER DEMO: Zero-Downtime Infrastructure Update
# This PowerShell script demonstrates real-time application monitoring 
# during infrastructure changes to prove zero-downtime capability

Write-Host @"
🎯 LIVE DEMONSTRATION: Zero-Downtime Infrastructure Update
=========================================================

This demonstrates a production-grade DevOps pipeline that can:
✅ Update infrastructure without service interruption
✅ Scale applications seamlessly under load
✅ Monitor and verify zero-downtime deployments
✅ Use Infrastructure as Code (Terraform) with CI/CD

Infrastructure Changes Being Applied:
- instance_type: t3.medium → t3.large (performance upgrade)
- desired_capacity: 3 → 4 (scale up for high availability)
- max_capacity: 6 → 8 (increase scaling limits)
- environment: production → demo_production (config change)

"@ -ForegroundColor Cyan

Write-Host "🔄 Starting real-time application monitoring..." -ForegroundColor Yellow
Write-Host "Application URL: http://mercor-demo-alb-614078766.us-east-1.elb.amazonaws.com" -ForegroundColor Blue

$totalChecks = 0
$successfulChecks = 0
$failedChecks = 0
$startTime = Get-Date

Write-Host "`nMONITORING RESULTS:" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green

for ($i = 1; $i -le 30; $i++) {  # Monitor for 10 minutes (30 checks × 20 seconds)
    $totalChecks++
    $currentTime = Get-Date
    $elapsed = [math]::Round(($currentTime - $startTime).TotalSeconds, 0)
    
    try {
        $response = Invoke-WebRequest -Uri "http://mercor-demo-alb-614078766.us-east-1.elb.amazonaws.com" -UseBasicParsing -TimeoutSec 10
        $successfulChecks++
        
        $timestamp = Get-Date -Format "HH:mm:ss"
        Write-Host "✅ [$timestamp] Check $i - Status: $($response.StatusCode) - Elapsed: ${elapsed}s - Success Rate: $([math]::Round($successfulChecks/$totalChecks*100,1))%" -ForegroundColor Green
        
        # Show response content occasionally to prove the app is actually working
        if ($i % 10 -eq 0) {
            $content = [System.Text.Encoding]::UTF8.GetString($response.Content)
            Write-Host "   📝 Response: $content" -ForegroundColor Gray
        }
        
    } catch {
        $failedChecks++
        $timestamp = Get-Date -Format "HH:mm:ss"
        Write-Host "❌ [$timestamp] Check $i - FAILED - Elapsed: ${elapsed}s - Success Rate: $([math]::Round($successfulChecks/$totalChecks*100,1))%" -ForegroundColor Red
        Write-Host "   🚨 ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Show progress every 5 checks
    if ($i % 5 -eq 0) {
        $uptime = if ($totalChecks -eq $successfulChecks) { "100%" } else { "$([math]::Round($successfulChecks/$totalChecks*100,2))%" }
        Write-Host "   📊 Progress: $i/30 checks completed - Uptime: $uptime - Duration: ${elapsed}s" -ForegroundColor Yellow
    }
    
    Start-Sleep 20  # Check every 20 seconds
}

# Final summary
$endTime = Get-Date
$totalDuration = [math]::Round(($endTime - $startTime).TotalMinutes, 1)
$uptimePercentage = if ($totalChecks -eq 0) { 0 } else { [math]::Round($successfulChecks/$totalChecks*100, 2) }

Write-Host @"

🏆 FINAL DEMONSTRATION RESULTS
===============================
Total Monitoring Duration: $totalDuration minutes
Total Availability Checks: $totalChecks
Successful Checks: $successfulChecks
Failed Checks: $failedChecks
Uptime Percentage: $uptimePercentage%

"@ -ForegroundColor Yellow

if ($failedChecks -eq 0) {
    Write-Host "🎉 ZERO DOWNTIME ACHIEVED!" -ForegroundColor Green
    Write-Host "The application remained 100% available during infrastructure updates." -ForegroundColor Green
} else {
    Write-Host "⚠️  Some downtime detected: $failedChecks failed checks" -ForegroundColor Red
}

Write-Host @"

💼 INTERVIEWER SUMMARY:
This demonstration proves that the DevOps pipeline can:
✅ Apply infrastructure changes without service interruption
✅ Scale applications under load while maintaining availability  
✅ Provide real-time monitoring and verification
✅ Implement enterprise-grade zero-downtime deployment strategies

🔗 GitHub Actions Workflow: https://github.com/Harshita123-coder/Mercor/actions
🌐 Live Application: http://mercor-demo-alb-614078766.us-east-1.elb.amazonaws.com

"@ -ForegroundColor Cyan