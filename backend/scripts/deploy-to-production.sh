#!/bin/bash

# ============================================================================
# Kram - Complete Production Deployment Script
# ============================================================================
# This script:
# 1. Starts AWS services (RDS database)
# 2. Runs database migrations on production
# 3. Optionally seeds the database
# 4. Deploys application to AWS Lightsail
# 5. Verifies deployment
#
# NOTE: Your local .env stays unchanged - local dev keeps working!
# ============================================================================

set -e  # Exit on error

# Change to backend directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
SERVICE_NAME="kram"
REGION="ap-south-1"
AWS_PROFILE="kram"

echo ""
echo -e "${BOLD}${CYAN}========================================${NC}"
echo -e "${BOLD}${CYAN}🚀 Kram Production Deployment${NC}"
echo -e "${BOLD}${CYAN}========================================${NC}"
echo ""

# ============================================================================
# PHASE 1: VALIDATION
# ============================================================================
echo -e "${BOLD}${BLUE}Phase 1: Validation${NC}"
echo -e "${BLUE}────────────────────${NC}"
echo ""

# Check if .env.production exists
if [ ! -f ".env.production" ]; then
    echo -e "${RED}❌ .env.production not found!${NC}"
    echo "This file is required for production deployment"
    exit 1
fi
echo -e "${GREEN}✅ .env.production found${NC}"

# Check if lightsail-deploy.sh exists
if [ ! -f "scripts/lightsail-deploy.sh" ]; then
    echo -e "${RED}❌ scripts/lightsail-deploy.sh not found!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ lightsail-deploy.sh found${NC}"

# Verify AWS credentials
if ! aws sts get-caller-identity --profile "$AWS_PROFILE" &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured for profile: $AWS_PROFILE${NC}"
    echo "Run: aws configure --profile $AWS_PROFILE"
    exit 1
fi
echo -e "${GREEN}✅ AWS credentials configured${NC}"
echo ""

# ============================================================================
# PHASE 2: START AWS SERVICES
# ============================================================================
echo -e "${BOLD}${BLUE}Phase 2: Starting AWS Services${NC}"
echo -e "${BLUE}────────────────────────────────${NC}"
echo ""

echo -e "${YELLOW}☁️  Starting AWS RDS database...${NC}"
./scripts/aws-start.sh

echo ""
echo -e "${YELLOW}⏳ Waiting for RDS to be fully available...${NC}"
echo -e "${YELLOW}   This may take 2-3 minutes...${NC}"
echo ""

# Poll RDS status
for i in {1..60}; do
    RDS_STATUS=$(aws rds describe-db-instances \
        --db-instance-identifier kram-db \
        --region "$REGION" \
        --profile "$AWS_PROFILE" \
        --query 'DBInstances[0].DBInstanceStatus' \
        --output text 2>/dev/null || echo "error")
    
    if [ "$RDS_STATUS" = "available" ]; then
        echo -e "${GREEN}✅ RDS database is available${NC}"
        break
    elif [ "$RDS_STATUS" = "error" ]; then
        echo -e "${RED}❌ Failed to check RDS status${NC}"
        exit 1
    fi
    
    echo -ne "${CYAN}   Status: $RDS_STATUS ... ${NC}"
    echo -ne "\r"
    sleep 5
done
echo ""

# ============================================================================
# PHASE 3: DATABASE MIGRATIONS
# ============================================================================
echo -e "${BOLD}${BLUE}Phase 3: Database Migrations${NC}"
echo -e "${BLUE}─────────────────────────────${NC}"
echo ""

# Load DATABASE_URL from .env.production
PROD_DATABASE_URL=$(grep "^DATABASE_URL=" .env.production | cut -d '=' -f2 | tr -d '"' | tr -d "'")

if [ -z "$PROD_DATABASE_URL" ]; then
    echo -e "${RED}❌ DATABASE_URL not found in .env.production${NC}"
    exit 1
fi

echo -e "${YELLOW}📊 Running Prisma migrations on production database...${NC}"
echo -e "${BLUE}   Database: ${PROD_DATABASE_URL:0:50}...${NC}"
echo ""

# Generate Prisma client
echo -e "${YELLOW}🔧 Generating Prisma client...${NC}"
if DATABASE_URL="$PROD_DATABASE_URL" npm run db:generate; then
    echo -e "${GREEN}✅ Prisma client generated${NC}"
else
    echo -e "${RED}❌ Prisma client generation failed${NC}"
    exit 1
fi
echo ""

# Run migrations
echo -e "${YELLOW}🚀 Deploying migrations...${NC}"
if DATABASE_URL="$PROD_DATABASE_URL" npx prisma migrate deploy; then
    echo -e "${GREEN}✅ Migrations deployed successfully${NC}"
else
    echo -e "${RED}❌ Migration deployment failed${NC}"
    echo "Check your database connection and migration files"
    exit 1
fi
echo ""

# Check migration status
echo -e "${YELLOW}🔍 Verifying migration status...${NC}"
DATABASE_URL="$PROD_DATABASE_URL" npx prisma migrate status
echo ""

# ============================================================================
# SEEDING DISABLED FOR PRODUCTION
# ============================================================================
# Database seeding is intentionally disabled for production deployments
# to prevent test data from being added to the production database.
# Only migrations are applied to ensure schema updates without test data.
echo -e "${BLUE}ℹ️  Database seeding is disabled for production deployments${NC}"
echo -e "${BLUE}   Only migrations will be applied to update the schema${NC}"
echo ""

# ============================================================================
# PHASE 4: DEPLOY TO LIGHTSAIL
# ============================================================================
echo -e "${BOLD}${BLUE}Phase 4: Deploying to AWS Lightsail${NC}"
echo -e "${BLUE}─────────────────────────────────────${NC}"
echo ""

echo -e "${YELLOW}🚀 Starting Lightsail deployment...${NC}"
echo -e "${BLUE}   (This will use .env.production for deployment)${NC}"
echo ""

if ./scripts/lightsail-deploy.sh; then
    echo ""
    echo -e "${GREEN}✅ Lightsail deployment completed${NC}"
else
    echo ""
    echo -e "${RED}❌ Lightsail deployment failed${NC}"
    exit 1
fi
echo ""

# ============================================================================
# PHASE 5: VERIFICATION
# ============================================================================
echo -e "${BOLD}${BLUE}Phase 5: Deployment Verification${NC}"
echo -e "${BLUE}────────────────────────────────${NC}"
echo ""

# Get service URL
echo -e "${YELLOW}🔍 Retrieving service URL...${NC}"
SERVICE_URL=$(aws lightsail get-container-services \
    --service-name "$SERVICE_NAME" \
    --region "$REGION" \
    --profile "$AWS_PROFILE" \
    --query 'containerServices[0].url' \
    --output text 2>/dev/null || echo "")

if [ -z "$SERVICE_URL" ]; then
    echo -e "${RED}❌ Could not retrieve service URL${NC}"
else
    echo -e "${GREEN}✅ Service URL: ${SERVICE_URL}${NC}"
    echo ""
    
    # Test health endpoint
    echo -e "${YELLOW}🏥 Testing health endpoint...${NC}"
    sleep 5  # Give it a moment to be ready
    
    if curl -f -s "${SERVICE_URL}/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Health check passed!${NC}"
    else
        echo -e "${YELLOW}⚠️  Health check failed (service may still be starting)${NC}"
        echo -e "${BLUE}   Check again in a minute: curl ${SERVICE_URL}/health${NC}"
    fi
fi
echo ""

# ============================================================================
# PHASE 6: INVALIDATE CLOUDFRONT CACHE
# ============================================================================
echo -e "${BOLD}${BLUE}Phase 6: CloudFront Cache Invalidation${NC}"
echo -e "${BLUE}────────────────────────────────────────${NC}"
echo ""

echo -e "${YELLOW}🔄 Invalidating CloudFront cache...${NC}"
echo -e "${BLUE}   This ensures users get the latest frontend build${NC}"
echo ""

# Call dedicated cache invalidation script
if ./scripts/invalidate-cloudfront-cache.sh; then
    echo -e "${GREEN}✅ CloudFront cache invalidation completed${NC}"
else
    echo -e "${YELLOW}⚠️  CloudFront cache invalidation failed${NC}"
    echo -e "${YELLOW}   You may need to invalidate manually:${NC}"
    echo -e "${CYAN}   ./scripts/invalidate-cloudfront-cache.sh${NC}"
fi
echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo -e "${BOLD}${GREEN}========================================${NC}"
echo -e "${BOLD}${GREEN}✅ DEPLOYMENT COMPLETE!${NC}"
echo -e "${BOLD}${GREEN}========================================${NC}"
echo ""
echo -e "${BOLD}Production Service:${NC}"
echo -e "  🌐 URL: ${BLUE}${SERVICE_URL}${NC}"
echo -e "  🗄️  Database: ${BLUE}kram-db (AWS RDS)${NC}"
echo -e "  📦 Container: ${BLUE}kram (AWS Lightsail)${NC}"
echo ""
echo -e "${BOLD}Local Development:${NC}"
echo -e "  💻 Database: ${GREEN}localhost:5432/kram${NC}"
echo -e "  📁 Config: ${GREEN}.env (unchanged)${NC}"
echo -e "  ✅ Your local dev environment is still working!${NC}"
echo ""
echo -e "${BOLD}Next Steps:${NC}"
echo -e "  1. ⏳ Wait 3-5 minutes for CloudFront cache to clear"
echo ""
echo -e "  2. Test production:"
echo -e "     API: ${CYAN}curl https://api.kramedu.in/health${NC}"
echo -e "     Dashboard: ${CYAN}https://dashboard.kramedu.in${NC}"
echo ""
echo -e "  3. Check Lightsail logs:"
echo -e "     ${CYAN}aws lightsail get-container-log --service-name kram --profile kram${NC}"
echo ""
echo -e "  4. View in AWS Console:"
echo -e "     ${CYAN}https://lightsail.aws.amazon.com/ls/webapp/ap-south-1/container-services/kram${NC}"
echo ""
echo -e "  5. To save costs when not using production:"
echo -e "     ${CYAN}./scripts/aws-stop.sh${NC}"
echo ""
echo -e "${BOLD}${GREEN}🎉 Deployment successful!${NC}"
echo ""
