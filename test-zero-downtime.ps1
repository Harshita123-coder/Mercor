$endpoint = "http://mercor-demo-alb-614078766.us-east-1.elb.amazonaws.com/"
$logFile = "deployment-test-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

Write-Host "Starting zero-downtime deployment test..."
Write-Host "Endpoint: $endpoint"
Write-Host "Log file: $logFile"
Write-Host "Press Ctrl+C to stop`n"

$counter = 0
while ($true) {
    $counter++
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    
    try {
        $response = Invoke-WebRequest -Uri $endpoint -TimeoutSec 5 -UseBasicParsing
        $status = $response.StatusCode
        $contentLength = $response.Content.Length
        
        # Extract message from response to detect version changes
        if ($response.Content -match '<h1>(.*?)</h1>') {
            $message = $matches[1]
        } else {
            $message = "Unknown"
        }
        
        $logEntry = "$timestamp [Test #$counter] Status: $status | Length: $contentLength | Message: $message"
        Write-Host $logEntry -ForegroundColor Green
        Add-Content -Path $logFile -Value $logEntry
        
    } catch {
        $error = $_.Exception.Message
        $logEntry = "$timestamp [Test #$counter] ERROR: $error"
        Write-Host $logEntry -ForegroundColor Red
        Add-Content -Path $logFile -Value $logEntry
    }
    
    Start-Sleep -Seconds 2
}