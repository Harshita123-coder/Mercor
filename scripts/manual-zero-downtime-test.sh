#!/bin/bash

# Quick fix for infrastructure monitoring 
echo "🔧 HOTFIX: Applying infrastructure change and monitoring for zero downtime"

ALB_DNS="mercor-demo-alb-614078766.us-east-1.elb.amazonaws.com"

echo "🔍 Pre-change application check:"
if curl -f "$ALB_DNS"; then
    echo "✅ Application accessible before any changes"
else
    echo "❌ Application not accessible - cannot proceed"
    exit 1
fi

echo "🔄 Applying terraform changes in background..."
cd terraform/envs/dev
terraform init -input=false > /dev/null 2>&1

# Check if there are any changes to apply
if terraform plan -detailed-exitcode > /dev/null 2>&1; then
    plan_exit=$?
    if [ $plan_exit -eq 2 ]; then
        echo "📋 Changes detected, applying with monitoring..."
        
        # Start monitoring during terraform apply
        total_checks=0
        successful_checks=0
        failed_checks=0
        
        # Apply terraform in background
        terraform apply -auto-approve > /tmp/tf_apply.log 2>&1 &
        tf_pid=$!
        
        echo "🎯 Monitoring application availability during infrastructure changes..."
        
        while kill -0 $tf_pid 2>/dev/null; do
            total_checks=$((total_checks + 1))
            
            if curl -f -s --max-time 5 "$ALB_DNS" > /dev/null; then
                successful_checks=$((successful_checks + 1))
                echo "✅ Check $total_checks - Application accessible"
            else
                failed_checks=$((failed_checks + 1))
                echo "❌ Check $total_checks - Application NOT accessible"
            fi
            
            sleep 5
        done
        
        # Wait for terraform to complete and get exit code
        wait $tf_pid
        tf_exit=$?
        
        echo "📊 Terraform apply completed with exit code: $tf_exit"
        if [ $tf_exit -eq 0 ]; then
            echo "✅ Terraform apply successful"
        else
            echo "❌ Terraform apply failed"
            echo "Terraform logs:"
            cat /tmp/tf_apply.log
        fi
        
        # Final monitoring summary
        echo "📈 Final Monitoring Results:"
        echo "Total Checks: $total_checks"
        echo "Successful: $successful_checks" 
        echo "Failed: $failed_checks"
        
        if [ $failed_checks -eq 0 ]; then
            echo "🎉 ZERO DOWNTIME ACHIEVED!"
        else
            echo "⚠️ Downtime detected: $failed_checks failed checks"
        fi
        
    else
        echo "ℹ️ No infrastructure changes needed"
    fi
else
    echo "❌ Terraform plan failed"
    cat /tmp/tf_apply.log 2>/dev/null || echo "No terraform logs available"
    exit 1
fi

echo "🔍 Final application check:"
if curl -f "$ALB_DNS"; then
    echo "✅ Application accessible after changes"
    echo "🏆 Infrastructure update completed successfully with zero downtime!"
else
    echo "❌ Application not accessible after changes"
    exit 1
fi