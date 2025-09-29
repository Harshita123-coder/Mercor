#!/bin/bash

# Infrastructure Update Demo Script
# Demonstrates true zero-downtime infrastructure updates with ECS on EC2

set -e

echo "🚀 Zero-Downtime Infrastructure Update Demo"
echo "============================================="

# Application URL for monitoring
ALB_URL="http://mercor-demo-alb-614078766.us-east-1.elb.amazonaws.com"
TERRAFORM_DIR="terraform/envs/dev"

# Function to check application availability
check_availability() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local response=$(curl -s -o /dev/null -w "%{http_code}" "$ALB_URL" || echo "000")
    
    if [ "$response" = "200" ]; then
        echo "[$timestamp] ✅ Application available (HTTP $response)"
        return 0
    else
        echo "[$timestamp] ❌ Application unavailable (HTTP $response)"
        return 1
    fi
}

# Function to monitor during infrastructure changes
monitor_availability() {
    local duration=$1
    local start_time=$(date +%s)
    local end_time=$((start_time + duration))
    local check_count=0
    local success_count=0
    
    echo "🔍 Starting continuous monitoring for ${duration} seconds..."
    
    while [ $(date +%s) -lt $end_time ]; do
        ((check_count++))
        if check_availability; then
            ((success_count++))
        fi
        sleep 15  # Check every 15 seconds
    done
    
    echo "📊 Monitoring Results:"
    echo "   Total Checks: $check_count"
    echo "   Successful: $success_count"
    echo "   Availability: $((success_count * 100 / check_count))%"
    
    if [ $success_count -eq $check_count ]; then
        echo "🎉 ZERO-DOWNTIME ACHIEVED!"
        return 0
    else
        echo "⚠️  Some downtime detected"
        return 1
    fi
}

# Function to demonstrate instance type upgrade
demo_instance_type_upgrade() {
    echo "🔧 Demo 1: Instance Type Upgrade (t3.small → t3.medium)"
    echo "========================================================="
    
    # Update variable
    cd "$TERRAFORM_DIR"
    sed -i 's/default.*=.*"t3\.small"/default     = "t3.medium"/' variables.tf
    
    echo "📝 Updated instance type to t3.medium"
    echo "🔄 Starting infrastructure update..."
    
    # Start monitoring in background
    monitor_availability 300 &  # Monitor for 5 minutes
    MONITOR_PID=$!
    
    # Apply infrastructure changes
    terraform plan -out=upgrade.tfplan
    terraform apply -auto-approve upgrade.tfplan
    
    # Wait for monitoring to complete
    wait $MONITOR_PID
    
    echo "✅ Instance type upgrade completed"
    echo ""
}

# Function to demonstrate capacity scaling
demo_capacity_scaling() {
    echo "🔧 Demo 2: Capacity Scaling (2 → 4 instances)"
    echo "=============================================="
    
    # Update variable
    cd "$TERRAFORM_DIR"
    sed -i 's/default.*=.*2.*# Start with 2 instances/default     = 4  # Scaled to 4 instances/' variables.tf
    
    echo "📝 Updated desired capacity to 4 instances"
    echo "🔄 Starting scaling operation..."
    
    # Start monitoring
    monitor_availability 240 &  # Monitor for 4 minutes
    MONITOR_PID=$!
    
    # Apply changes
    terraform plan -out=scale.tfplan
    terraform apply -auto-approve scale.tfplan
    
    wait $MONITOR_PID
    
    echo "✅ Capacity scaling completed"
    echo ""
}

# Function to demonstrate AMI update
demo_ami_update() {
    echo "🔧 Demo 3: AMI Update (Force Latest ECS-Optimized AMI)"
    echo "===================================================="
    
    # Force AMI update by getting latest AMI ID
    LATEST_AMI=$(aws ec2 describe-images \
        --owners amazon \
        --filters "Name=name,Values=al2023-ami-ecs-hvm-*-x86_64" \
        --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
        --output text)
    
    cd "$TERRAFORM_DIR"
    sed -i "s/default.*=.*null.*/default     = \"$LATEST_AMI\"  # Force latest AMI update/" variables.tf
    
    echo "📝 Updated AMI ID to: $LATEST_AMI"
    echo "🔄 Starting AMI rollout with Auto Scaling Group instance refresh..."
    
    # Start monitoring
    monitor_availability 360 &  # Monitor for 6 minutes (AMI updates take longer)
    MONITOR_PID=$!
    
    # Apply changes
    terraform plan -out=ami.tfplan
    terraform apply -auto-approve ami.tfplan
    
    wait $MONITOR_PID
    
    echo "✅ AMI update completed"
    echo ""
}

# Main demo execution
main() {
    echo "🎯 This demo shows true infrastructure-level zero-downtime updates:"
    echo "   • Instance type changes (t3.small → t3.medium)"
    echo "   • Auto Scaling Group capacity changes"
    echo "   • AMI updates with instance refresh"
    echo ""
    echo "💡 These are only possible with ECS on EC2 + Auto Scaling Groups"
    echo "   (Not possible with Fargate - no infrastructure to update!)"
    echo ""
    
    # Initial availability check
    echo "🏁 Initial application check:"
    check_availability
    echo ""
    
    # Run demos
    demo_instance_type_upgrade
    demo_capacity_scaling
    demo_ami_update
    
    echo "🎉 All infrastructure updates completed with zero downtime!"
    echo "📊 This demonstrates true infrastructure-level rolling updates"
    echo "   while maintaining 100% application availability."
}

# Run the demo
main "$@"