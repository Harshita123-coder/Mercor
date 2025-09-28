#!/bin/bash

# Zero Downtime Test Script
# This script continuously monitors application availability during infrastructure updates

ALB_DNS="mercor-demo-alb-614078766.us-east-1.elb.amazonaws.com"
TEST_DURATION=${1:-300}  # Default 5 minutes
CHECK_INTERVAL=${2:-5}   # Default 5 seconds

echo "🚀 Starting Zero-Downtime Test"
echo "📡 Target: http://$ALB_DNS"
echo "⏱️  Duration: ${TEST_DURATION} seconds"
echo "🔄 Check Interval: ${CHECK_INTERVAL} seconds"
echo "----------------------------------------"

start_time=$(date +%s)
end_time=$((start_time + TEST_DURATION))
total_requests=0
successful_requests=0
failed_requests=0

# Create log file
log_file="zero_downtime_test_$(date +%Y%m%d_%H%M%S).log"
echo "Test started at $(date)" > "$log_file"

while [ $(date +%s) -lt $end_time ]; do
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))
    
    # Make HTTP request
    if curl -f -s --max-time 5 "http://$ALB_DNS" > /dev/null 2>&1; then
        successful_requests=$((successful_requests + 1))
        status="✅ SUCCESS"
    else
        failed_requests=$((failed_requests + 1))
        status="❌ FAILED"
    fi
    
    total_requests=$((total_requests + 1))
    success_rate=$(( (successful_requests * 100) / total_requests ))
    
    # Log and display result
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    log_entry="[$timestamp] Request #$total_requests - $status - Success Rate: ${success_rate}%"
    echo "$log_entry"
    echo "$log_entry" >> "$log_file"
    
    # Display running statistics every 10 requests
    if [ $((total_requests % 10)) -eq 0 ]; then
        echo "📊 Stats: ${successful_requests}/${total_requests} successful (${success_rate}%) | Elapsed: ${elapsed}s"
        echo "----------------------------------------"
    fi
    
    sleep $CHECK_INTERVAL
done

# Final statistics
echo ""
echo "🏁 Zero-Downtime Test Complete"
echo "📊 Final Statistics:"
echo "   Total Requests: $total_requests"
echo "   Successful: $successful_requests"
echo "   Failed: $failed_requests" 
echo "   Success Rate: ${success_rate}%"
echo "   Test Duration: $(($(date +%s) - start_time)) seconds"

if [ $failed_requests -eq 0 ]; then
    echo "🎉 PERFECT SCORE: Zero downtime achieved!"
    exit 0
elif [ $success_rate -ge 99 ]; then
    echo "✅ EXCELLENT: Near-zero downtime achieved!"
    exit 0
elif [ $success_rate -ge 95 ]; then
    echo "👍 GOOD: Minimal downtime observed"
    exit 0
else
    echo "⚠️  NEEDS IMPROVEMENT: Significant downtime detected"
    exit 1
fi