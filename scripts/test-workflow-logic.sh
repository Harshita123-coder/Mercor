#!/bin/bash

# Quick test script to verify our infrastructure update workflow logic
echo "🧪 Testing Zero-Downtime Workflow Logic Locally"

# Set variables
ALB_DNS="mercor-demo-alb-614078766.us-east-1.elb.amazonaws.com"
CLUSTER_NAME="mercor-demo-cluster"
SERVICE_NAME="mercor-demo-fargate-svc"

echo "🔍 Pre-update health check:"
if curl -f "http://$ALB_DNS"; then
  echo "✅ Application accessible"
else
  echo "❌ Application not accessible"
  exit 1
fi

echo "📊 Current ECS Service State:"
aws ecs describe-services \
  --cluster $CLUSTER_NAME \
  --services $SERVICE_NAME \
  --query 'services[0].[serviceName,status,runningCount,pendingCount,desiredCount,platformVersion]' \
  --output table

echo "🎯 Testing application availability monitoring..."
consecutive_successes=0
for i in {1..5}; do
  if curl -f -s "http://$ALB_DNS" > /dev/null; then
    consecutive_successes=$((consecutive_successes + 1))
    echo "✅ Check $i: Application accessible (${consecutive_successes} consecutive)"
  else
    consecutive_successes=0
    echo "❌ Check $i: Application not accessible"
  fi
  sleep 2
done

if [ $consecutive_successes -ge 3 ]; then
  echo "🎉 Application is consistently accessible!"
else
  echo "⚠️  Application accessibility is inconsistent"
fi

echo "✅ Local test completed successfully!"