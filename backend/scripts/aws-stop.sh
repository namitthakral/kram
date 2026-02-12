#!/bin/bash

# Script to STOP AWS services and save money
# Run this when you want to pause your application

set -e

echo "🛑 Stopping AWS Services to Save Money"
echo "========================================"
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
echo "🗄️  Database: $DB_INSTANCE"
echo ""

# Note about Lightsail Container Service
echo "1️⃣  Lightsail Container Service:"
echo "   ⚠️  AWS Lightsail does NOT support scaling to 0"
echo "   ⚠️  Minimum scale is 1 replica (always running)"
echo ""
echo "   Options to save money on Lightsail:"
echo "   a) Keep running (cheapest plan is ~$10/month)"
echo "   b) Delete the service entirely (run ./scripts/aws-delete-lightsail.sh)"
echo ""
echo "   ⚠️  Skipping Lightsail stop (not supported by AWS)"
echo ""

# Stop RDS Database
echo "2️⃣  Stopping RDS Database..."
echo "   (Database will stop and save ~$12/month)"
echo "   Note: AWS auto-starts stopped DB after 7 days"
echo ""

aws rds stop-db-instance \
  --db-instance-identifier "$DB_INSTANCE" \
  --region "$REGION" \
  --profile "$AWS_PROFILE" \
  2>/dev/null || echo "⚠️  Database already stopped or doesn't exist"

echo "✅ RDS database stopping (takes 2-3 minutes)"
echo ""

echo "💰 Cost Savings Estimate:"
echo "   • Lightsail: ~$10/month → ~$10/month (can't stop, min scale is 1)"
echo "   • RDS (stopped): ~$12/month → $1/month (storage only)"
echo "   • Total savings: ~$11/month"
echo ""
echo "⚠️  Important Notes:"
echo "   1. Lightsail is STILL RUNNING (AWS doesn't support stopping it)"
echo "   2. Database is STOPPED (saves ~$11/month)"
echo "   3. Database auto-restarts after 7 days of being stopped"
echo "   4. To fully stop Lightsail, you must delete it: ./scripts/aws-delete-lightsail.sh"
echo "   5. To restart database only: ./scripts/aws-start.sh"
echo ""
echo "✅ AWS services stopped successfully!"
