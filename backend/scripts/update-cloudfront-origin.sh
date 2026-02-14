#!/bin/bash

# ============================================================================
# Update CloudFront Origin Script
# ============================================================================
# WHEN TO USE THIS:
#   - Only when Lightsail service URL changes (rare)
#   - This happens if you delete and recreate the Lightsail container service
#
# FOR REGULAR DEPLOYMENTS:
#   - Use deploy-to-production.sh (handles everything automatically)
#   - Or use invalidate-cloudfront-cache.sh (just clears cache)
# ============================================================================

set -e

echo "🔄 Update CloudFront Origin"
echo "==========================="
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
CLOUDFRONT_ID="E36FPX6Q6TAGJV"

echo "Getting current Lightsail URL..."

# Get the new Lightsail URL
NEW_URL=$(aws lightsail get-container-services \
  --service-name "$SERVICE_NAME" \
  --region "$REGION" \
  --profile "$AWS_PROFILE" \
  --query 'containerServices[0].url' \
  --output text)

if [ -z "$NEW_URL" ] || [ "$NEW_URL" == "None" ]; then
  echo "❌ Could not get Lightsail URL. Is the service deployed?"
  exit 1
fi

echo "✅ Current Lightsail URL: $NEW_URL"
echo ""

# Get current CloudFront origin
echo "Checking CloudFront distribution..."
CURRENT_ORIGIN=$(aws cloudfront get-distribution \
  --id "$CLOUDFRONT_ID" \
  --profile "$AWS_PROFILE" \
  --query 'Distribution.DistributionConfig.Origins.Items[0].DomainName' \
  --output text)

echo "📊 Current CloudFront origin: $CURRENT_ORIGIN"
echo "📊 New Lightsail URL: $NEW_URL"
echo ""

if [ "$CURRENT_ORIGIN" == "$NEW_URL" ]; then
  echo "✅ CloudFront origin already matches! No update needed."
  exit 0
fi

echo "⚠️  CloudFront origin needs updating"
echo ""
read -p "Update CloudFront origin? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Cancelled"
  exit 1
fi

echo ""
echo "Updating CloudFront distribution..."

# Get current distribution config
aws cloudfront get-distribution-config \
  --id "$CLOUDFRONT_ID" \
  --profile "$AWS_PROFILE" \
  > /tmp/cf-config.json

ETAG=$(jq -r '.ETag' /tmp/cf-config.json)

# Update the origin domain name
jq --arg newurl "$NEW_URL" \
  '.DistributionConfig.Origins.Items[0].DomainName = $newurl | 
   .DistributionConfig.Origins.Items[0].Id = $newurl |
   .DistributionConfig.DefaultCacheBehavior.TargetOriginId = $newurl' \
  /tmp/cf-config.json > /tmp/cf-config-updated.json

# Extract just the DistributionConfig
jq '.DistributionConfig' /tmp/cf-config-updated.json > /tmp/cf-dist-config.json

# Update CloudFront
aws cloudfront update-distribution \
  --id "$CLOUDFRONT_ID" \
  --distribution-config file:///tmp/cf-dist-config.json \
  --if-match "$ETAG" \
  --profile "$AWS_PROFILE" \
  > /dev/null

echo "✅ CloudFront origin updated!"
echo ""

# Invalidate cache
echo "Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
  --distribution-id "$CLOUDFRONT_ID" \
  --paths "/*" \
  --profile "$AWS_PROFILE" \
  > /dev/null

echo "✅ CloudFront cache invalidated!"
echo ""

# Cleanup
rm -f /tmp/cf-config.json /tmp/cf-config-updated.json /tmp/cf-dist-config.json

echo "🎉 All done!"
echo ""
echo "✅ CloudFront now points to: $NEW_URL"
echo "✅ Your custom domains should work in 2-3 minutes"
echo ""
echo "Test your API:"
echo "  curl https://api.kramedu.in/health"
