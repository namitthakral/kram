#!/bin/bash

# Script to CHECK the status of AWS services

set -e

echo "📊 AWS Services Status Check"
echo "============================="
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Load environment variables
if [ -f "$PROJECT_ROOT/.env" ]; then
  source "$PROJECT_ROOT/.env"
else
  echo "❌ .env file not found at: $PROJECT_ROOT/.env"
  exit 1
fi

SERVICE_NAME="${SERVICE_NAME:-kram}"
REGION="${LIGHTSAIL_REGION:-ap-south-1}"
AWS_PROFILE="${AWS_PROFILE:-kram}"
DB_INSTANCE="kram-db"

echo "📦 Service: $SERVICE_NAME"
echo "🌍 Region: $REGION"
echo ""

# Check Lightsail Container Service
echo "1️⃣  Lightsail Container Service:"
LIGHTSAIL_STATUS=$(aws lightsail get-container-services \
  --service-name "$SERVICE_NAME" \
  --region "$REGION" \
  --profile "$AWS_PROFILE" \
  --query 'containerServices[0].[state, scale, url]' \
  --output text 2>/dev/null || echo "ERROR")

if [ "$LIGHTSAIL_STATUS" != "ERROR" ]; then
  STATE=$(echo "$LIGHTSAIL_STATUS" | awk '{print $1}')
  SCALE=$(echo "$LIGHTSAIL_STATUS" | awk '{print $2}')
  URL=$(echo "$LIGHTSAIL_STATUS" | awk '{print $3}')
  
  echo "   Status: $STATE"
  echo "   Scale: $SCALE replicas"
  echo "   URL: https://$URL"
  
  if [ "$SCALE" = "0" ]; then
    echo "   💤 Service is STOPPED (no charges)"
  else
    echo "   ✅ Service is RUNNING (~$10/month)"
  fi
else
  echo "   ❌ Could not fetch status"
fi

echo ""

# Check RDS Database
echo "2️⃣  RDS Database:"
DB_STATUS=$(aws rds describe-db-instances \
  --db-instance-identifier "$DB_INSTANCE" \
  --region "$REGION" \
  --profile "$AWS_PROFILE" \
  --query 'DBInstances[0].[DBInstanceStatus, Endpoint.Address]' \
  --output text 2>/dev/null || echo "ERROR")

if [ "$DB_STATUS" != "ERROR" ]; then
  STATUS=$(echo "$DB_STATUS" | awk '{print $1}')
  ENDPOINT=$(echo "$DB_STATUS" | awk '{print $2}')
  
  echo "   Status: $STATUS"
  echo "   Endpoint: $ENDPOINT"
  
  case "$STATUS" in
    "available")
      echo "   ✅ Database is RUNNING (~$12/month)"
      ;;
    "stopped")
      echo "   💤 Database is STOPPED (~$1/month for storage)"
      ;;
    "stopping"|"starting")
      echo "   ⏳ Database is transitioning..."
      ;;
    *)
      echo "   ⚠️  Status: $STATUS"
      ;;
  esac
else
  echo "   ❌ Could not fetch status"
fi

echo ""
echo "💡 Quick Actions:"
echo "   • Stop all services: ./scripts/aws-stop.sh"
echo "   • Start all services: ./scripts/aws-start.sh"
