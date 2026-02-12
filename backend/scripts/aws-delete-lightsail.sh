#!/bin/bash

# Script to DELETE Lightsail Container Service (saves ~$10/month)
# WARNING: This fully deletes the service. You'll need to redeploy to restart.

set -e

echo "🗑️  DELETE Lightsail Container Service"
echo "======================================"
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

echo "📦 Service: $SERVICE_NAME"
echo "🌍 Region: $REGION"
echo ""

echo "⚠️  ⚠️  ⚠️  WARNING ⚠️  ⚠️  ⚠️"
echo ""
echo "This will PERMANENTLY DELETE the Lightsail container service:"
echo "   • Your application will go OFFLINE"
echo "   • Container images will be deleted"
echo "   • Service configuration will be deleted"
echo "   • You'll need to redeploy from scratch to restart"
echo ""
echo "💰 Savings: ~$10/month"
echo ""
echo "✅ Your code and database are safe"
echo ""
read -p "Type 'DELETE' to confirm: " -r
echo
if [[ ! $REPLY == "DELETE" ]]; then
  echo "❌ Cancelled (you typed: '$REPLY', needed: 'DELETE')"
  exit 1
fi

echo ""
echo "Deleting Lightsail service..."

# Delete the container service
aws lightsail delete-container-service \
  --service-name "$SERVICE_NAME" \
  --region "$REGION" \
  --profile "$AWS_PROFILE"

echo ""
echo "✅ Lightsail service deleted successfully!"
echo ""
echo "💰 You are now saving ~$10/month on Lightsail"
echo ""
echo "📊 Current infrastructure:"
echo "   • Lightsail: DELETED ✅"
echo "   • Database: Check with ./scripts/aws-status.sh"
echo ""
echo "🚀 To redeploy your application:"
echo "   cd backend && ./scripts/lightsail-deploy.sh"
