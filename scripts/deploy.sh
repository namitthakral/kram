#!/bin/bash

# Ed-Verse Full Deployment Script
# This script builds the Flutter frontend, copies it to backend, builds backend, and deploys to EB

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the root directory (parent of scripts folder)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$ROOT_DIR/frontend"
BACKEND_DIR="$ROOT_DIR/backend"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Ed-Verse Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"

# Step 1: Build Flutter Web
echo -e "\n${YELLOW}[1/4] Building Flutter web app...${NC}"
cd "$FRONTEND_DIR"
flutter build web --base-href "/dashboard/"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Flutter build completed${NC}"
else
    echo -e "${RED}✗ Flutter build failed${NC}"
    exit 1
fi

# Step 2: Copy Flutter build to backend
echo -e "\n${YELLOW}[2/4] Copying Flutter build to backend...${NC}"
rm -rf "$BACKEND_DIR/public/dashboard/"*
cp -r "$FRONTEND_DIR/build/web/"* "$BACKEND_DIR/public/dashboard/"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Flutter build copied to backend/public/dashboard${NC}"
else
    echo -e "${RED}✗ Failed to copy Flutter build${NC}"
    exit 1
fi

# Step 3: Build Backend
echo -e "\n${YELLOW}[3/4] Building backend...${NC}"
cd "$BACKEND_DIR"
npm run build
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Backend build completed${NC}"
else
    echo -e "${RED}✗ Backend build failed${NC}"
    exit 1
fi

# Step 4: Deploy to Elastic Beanstalk
echo -e "\n${YELLOW}[4/4] Deploying to Elastic Beanstalk...${NC}"
eb deploy
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Deployment completed successfully${NC}"
else
    echo -e "${RED}✗ Deployment failed${NC}"
    exit 1
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}   Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Dashboard URL: http://ed-verse-api.eba-dx3z9kvh.ap-south-1.elasticbeanstalk.com/dashboard/"
echo -e "API Health:    http://ed-verse-api.eba-dx3z9kvh.ap-south-1.elasticbeanstalk.com/health"
