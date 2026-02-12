#!/bin/bash

# Script to START AWS services back up
# Run this when you want to use your application again

set -e

echo "🚀 Starting AWS Services"
echo "========================"
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

# Start RDS Database first (takes longer)
echo "1️⃣  Starting RDS Database..."
echo "   (This takes 2-3 minutes)"
echo ""

aws rds start-db-instance \
  --db-instance-identifier "$DB_INSTANCE" \
  --region "$REGION" \
  --profile "$AWS_PROFILE" \
  2>/dev/null || echo "⚠️  Database already running or error occurred"

echo "⏳ Waiting for database to be available..."
aws rds wait db-instance-available \
  --db-instance-identifier "$DB_INSTANCE" \
  --region "$REGION" \
  --profile "$AWS_PROFILE"

echo "✅ RDS database is now running"
echo ""

# Start Lightsail Container Service
echo "2️⃣  Starting Lightsail Container Service..."
echo "   (Scaling back to 1 replica)"
echo ""

aws lightsail update-container-service \
  --service-name "$SERVICE_NAME" \
  --scale 1 \
  --region "$REGION" \
  --profile "$AWS_PROFILE" \
  2>/dev/null || echo "⚠️  Container service already running or error occurred"

echo "✅ Lightsail service starting (takes 3-5 minutes to be fully ready)"
echo ""

# Get the service URL
echo "🌐 Getting service URL..."
SERVICE_URL=$(aws lightsail get-container-services \
  --service-name "$SERVICE_NAME" \
  --region "$REGION" \
  --profile "$AWS_PROFILE" \
  --query 'containerServices[0].url' \
  --output text 2>/dev/null || echo "unknown")

echo ""
echo "✅ AWS services started successfully!"
echo ""
echo "📊 Service Status:"
echo "   • Database: Running"
echo "   • API Service: Starting (wait 3-5 minutes)"
echo "   • Service URL: https://$SERVICE_URL"
echo ""
echo "⏳ Wait 3-5 minutes for the container to fully start"
echo "   Then test: curl https://$SERVICE_URL/health"
echo ""
echo "💰 Monthly costs resumed:"
echo "   • Lightsail: ~$10/month"
echo "   • RDS: ~$12/month"
echo "   • Total: ~$22/month"
