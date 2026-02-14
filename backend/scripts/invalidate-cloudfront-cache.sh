#!/bin/bash

# ============================================================================
# Simple CloudFront Cache Invalidation Script
# ============================================================================
# This script only invalidates CloudFront cache, nothing else.
# Use this after deployments to ensure users get the latest frontend build.
# ============================================================================

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
CLOUDFRONT_DISTRIBUTION_ID="E36FPX6Q6TAGJV"
AWS_PROFILE="${AWS_PROFILE:-kram}"

echo ""
echo -e "${BLUE}🔄 CloudFront Cache Invalidation${NC}"
echo -e "${BLUE}════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}📋 Distribution ID: ${CLOUDFRONT_DISTRIBUTION_ID}${NC}"
echo -e "${YELLOW}🔧 AWS Profile: ${AWS_PROFILE}${NC}"
echo ""

echo -e "${YELLOW}⏳ Creating cache invalidation...${NC}"

INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" \
    --paths "/*" \
    --profile "$AWS_PROFILE" \
    --query 'Invalidation.Id' \
    --output text 2>&1)

if [ $? -eq 0 ] && [[ ! "$INVALIDATION_ID" =~ "error" ]] && [[ ! "$INVALIDATION_ID" =~ "Error" ]]; then
    echo -e "${GREEN}✅ Cache invalidation initiated successfully!${NC}"
    echo -e "${BLUE}   Invalidation ID: ${INVALIDATION_ID}${NC}"
    echo ""
    echo -e "${YELLOW}⏳ Cache will be cleared in 3-5 minutes${NC}"
    echo ""
    echo -e "${GREEN}Your users will see the latest version after the invalidation completes.${NC}"
else
    echo -e "${RED}❌ Cache invalidation failed${NC}"
    echo -e "${YELLOW}Error: $INVALIDATION_ID${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Done!${NC}"
echo ""
