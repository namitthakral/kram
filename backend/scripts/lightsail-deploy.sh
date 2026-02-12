#!/bin/bash

# ============================================================================
# Ed-Verse Backend - AWS Lightsail Deployment Script
# ============================================================================

set -e  # Exit on error

# Change to backend directory (script must run from backend/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Add local bin to PATH for lightsailctl
export PATH="$HOME/bin:$PATH"

# Set Docker socket for OrbStack compatibility
export DOCKER_HOST="unix://$HOME/.orbstack/run/docker.sock"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SERVICE_NAME="kram"
REGION="ap-south-1"  # Mumbai region (change if needed)
CONTAINER_NAME="app"
PORT=3000
AWS_PROFILE="kram"  # Use existing kram profile

# Lightsail container service power/scale
# nano: 0.25 vCPU, 512 MB RAM - $7/month
# micro: 0.5 vCPU, 1 GB RAM - $10/month
# small: 1 vCPU, 2 GB RAM - $20/month
POWER="micro"
SCALE=1

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Ed-Verse Lightsail Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed${NC}"
    echo "Install it from: https://aws.amazon.com/cli/"
    exit 1
fi

echo -e "${GREEN}✅ AWS CLI found${NC}"

# Check AWS credentials
if ! aws sts get-caller-identity --profile "$AWS_PROFILE" &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured for profile: $AWS_PROFILE${NC}"
    echo "Run: aws configure --profile $AWS_PROFILE"
    exit 1
fi

echo -e "${GREEN}✅ AWS credentials configured${NC}"
echo ""

# Step 0: Check and rebuild Flutter frontend if needed
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}📱 Checking Flutter Frontend${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

FRONTEND_DIR="../frontend"
DASHBOARD_DIR="./public/dashboard"
REBUILD_FRONTEND=false

if [ -d "$FRONTEND_DIR" ]; then
    # Check if dashboard build exists
    if [ ! -d "$DASHBOARD_DIR" ] || [ ! -f "$DASHBOARD_DIR/main.dart.js" ]; then
        echo -e "${YELLOW}⚠️  Dashboard build not found${NC}"
        REBUILD_FRONTEND=true
    else
        # Compare modification times
        FRONTEND_LAST_MODIFIED=$(find "$FRONTEND_DIR/lib" -type f -name "*.dart" -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -1 | cut -d' ' -f1)
        DASHBOARD_LAST_BUILT=$(stat -f "%m" "$DASHBOARD_DIR/main.dart.js" 2>/dev/null)
        
        if [ -n "$FRONTEND_LAST_MODIFIED" ] && [ -n "$DASHBOARD_LAST_BUILT" ]; then
            if [ "$FRONTEND_LAST_MODIFIED" -gt "$DASHBOARD_LAST_BUILT" ]; then
                echo -e "${YELLOW}⚠️  Frontend code changed since last build${NC}"
                FRONTEND_LAST_MODIFIED_DATE=$(date -r "$FRONTEND_LAST_MODIFIED" "+%Y-%m-%d %H:%M:%S")
                DASHBOARD_LAST_BUILT_DATE=$(date -r "$DASHBOARD_LAST_BUILT" "+%Y-%m-%d %H:%M:%S")
                echo -e "${YELLOW}   Frontend modified: $FRONTEND_LAST_MODIFIED_DATE${NC}"
                echo -e "${YELLOW}   Dashboard built: $DASHBOARD_LAST_BUILT_DATE${NC}"
                REBUILD_FRONTEND=true
            else
                echo -e "${GREEN}✅ Dashboard is up to date${NC}"
            fi
        fi
    fi
    
    if [ "$REBUILD_FRONTEND" = true ]; then
        echo ""
        echo -e "${YELLOW}🔨 Rebuilding Flutter web app...${NC}"
        cd "$FRONTEND_DIR"
        
        # Check if flutter is installed
        if ! command -v flutter &> /dev/null; then
            echo -e "${RED}❌ Flutter not found!${NC}"
            echo -e "${YELLOW}Please install Flutter or build manually:${NC}"
            echo "  cd $FRONTEND_DIR"
            echo "  flutter build web --release"
            echo "  cp -r build/web/* ../backend/public/dashboard/"
            exit 1
        fi
        
        # Build Flutter web
        if flutter build web --release; then
            echo -e "${GREEN}✅ Flutter build successful${NC}"
            
            # Copy to backend
            cd - > /dev/null
            echo -e "${YELLOW}📦 Copying Flutter build to backend...${NC}"
            rm -rf "$DASHBOARD_DIR"/*
            cp -r "$FRONTEND_DIR/build/web"/* "$DASHBOARD_DIR/"
            echo -e "${GREEN}✅ Dashboard updated${NC}"
        else
            echo -e "${RED}❌ Flutter build failed${NC}"
            exit 1
        fi
        
        cd - > /dev/null
    fi
else
    echo -e "${YELLOW}⚠️  Frontend directory not found at: $FRONTEND_DIR${NC}"
    echo -e "${YELLOW}   Skipping frontend rebuild check${NC}"
fi

echo ""

# Step 1: Check if service exists
echo -e "${YELLOW}📋 Checking if Lightsail service exists...${NC}"
if aws lightsail get-container-services --service-name "$SERVICE_NAME" --region "$REGION" --profile "$AWS_PROFILE" &> /dev/null; then
    echo -e "${YELLOW}⚠️  Service '$SERVICE_NAME' already exists - will update it${NC}"
    UPDATE_MODE=true
else
    echo -e "${GREEN}✅ Service doesn't exist, will create new one${NC}"
    UPDATE_MODE=false
fi
echo ""

# Step 2: Build Docker image
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🐳 Building Docker Image${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}🔨 Building Docker image for linux/amd64...${NC}"
docker build --platform linux/amd64 -t "$SERVICE_NAME:latest" .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Docker image built successfully (kram:latest)${NC}"
else
    echo -e "${RED}❌ Docker build failed${NC}"
    exit 1
fi
echo ""

# Step 3: Create Lightsail container service (if needed)
if [ "$UPDATE_MODE" = false ]; then
    echo -e "${YELLOW}🚀 Creating Lightsail container service...${NC}"
    aws lightsail create-container-service \
        --service-name "$SERVICE_NAME" \
        --power "$POWER" \
        --scale "$SCALE" \
        --region "$REGION" \
        --profile "$AWS_PROFILE"
    
    echo -e "${GREEN}✅ Container service created${NC}"
    echo -e "${YELLOW}⏳ Waiting for service to be active (this takes 2-3 minutes)...${NC}"
    
    # Wait for service to be ready
    for i in {1..60}; do
        STATE=$(aws lightsail get-container-services --service-name "$SERVICE_NAME" --region "$REGION" --profile "$AWS_PROFILE" --query 'containerServices[0].state' --output text)
        if [ "$STATE" = "ACTIVE" ]; then
            echo -e "${GREEN}✅ Service is active${NC}"
            break
        fi
        echo -n "."
        sleep 5
    done
    echo ""
fi

# Step 4: Push image to Lightsail
echo -e "${YELLOW}📤 Pushing image to Lightsail...${NC}"
aws lightsail push-container-image \
    --service-name "$SERVICE_NAME" \
    --label "kram" \
    --image "kram:latest" \
    --region "$REGION" \
    --profile "$AWS_PROFILE"

# Get the pushed image name
IMAGE_NAME=$(aws lightsail get-container-images --service-name "$SERVICE_NAME" --region "$REGION" --profile "$AWS_PROFILE" --query 'containerImages[0].image' --output text)
echo -e "${GREEN}✅ Image pushed: $IMAGE_NAME${NC}"
echo ""

# Step 5: Load environment variables
echo -e "${YELLOW}⚙️  Loading production environment variables...${NC}"

# Always load from .env.production for deployment
if [ -f ".env.production" ]; then
    echo -e "${BLUE}Loading from .env.production file...${NC}"
    export $(grep -v '^#' .env.production | xargs)
elif [ -f "../.env.production" ]; then
    echo -e "${BLUE}Loading from ../.env.production file...${NC}"
    export $(grep -v '^#' ../.env.production | xargs)
else
    echo -e "${RED}❌ .env.production not found!${NC}"
    echo "Deployment requires .env.production file with production credentials"
    echo "This ensures deployment uses production database, not local development database"
    exit 1
fi

# Check if required environment variables are set
if [ -z "$DATABASE_URL" ]; then
    echo -e "${RED}❌ DATABASE_URL not set${NC}"
    echo "Please set environment variables or create a .env file"
    echo "See .env.example for reference"
    exit 1
fi

if [ -z "$JWT_SECRET" ]; then
    echo -e "${RED}❌ JWT_SECRET not set${NC}"
    echo "Please set environment variables or create a .env file"
    exit 1
fi

if [ -z "$JWT_REFRESH_SECRET" ]; then
    echo -e "${RED}❌ JWT_REFRESH_SECRET not set${NC}"
    echo "Please set environment variables or create a .env file"
    exit 1
fi

echo -e "${GREEN}✅ Production environment variables loaded${NC}"
echo -e "${BLUE}   DATABASE_URL: ${DATABASE_URL:0:40}...${NC}"
echo -e "${BLUE}   JWT_SECRET: ${JWT_SECRET:0:20}...${NC}"
echo -e "${BLUE}   JWT_REFRESH_SECRET: ${JWT_REFRESH_SECRET:0:20}...${NC}"
echo -e "${BLUE}   NODE_ENV: production${NC}"

# Create deployment JSON
cat > deployment.json <<EOF
{
  "serviceName": "$SERVICE_NAME",
  "containers": {
    "$CONTAINER_NAME": {
      "image": "$IMAGE_NAME",
      "environment": {
        "DATABASE_URL": "$DATABASE_URL",
        "JWT_SECRET": "$JWT_SECRET",
        "JWT_REFRESH_SECRET": "$JWT_REFRESH_SECRET",
        "NODE_ENV": "production",
        "PORT": "$PORT"
      },
      "ports": {
        "$PORT": "HTTP"
      }
    }
  },
  "publicEndpoint": {
    "containerName": "$CONTAINER_NAME",
    "containerPort": $PORT,
    "healthCheck": {
      "path": "/health",
      "intervalSeconds": 30,
      "timeoutSeconds": 10,
      "healthyThreshold": 2,
      "unhealthyThreshold": 3
    }
  }
}
EOF

echo -e "${GREEN}✅ Deployment configuration created${NC}"
echo ""

# Step 6: Deploy to Lightsail
echo -e "${YELLOW}🚀 Deploying to Lightsail...${NC}"
aws lightsail create-container-service-deployment \
    --region "$REGION" \
    --profile "$AWS_PROFILE" \
    --cli-input-json file://deployment.json

echo -e "${GREEN}✅ Deployment initiated${NC}"
echo ""

# Step 7: Wait for deployment
echo -e "${YELLOW}⏳ Waiting for deployment to complete (this takes 3-5 minutes)...${NC}"
for i in {1..60}; do
    DEPLOYMENT_STATE=$(aws lightsail get-container-services --service-name "$SERVICE_NAME" --region "$REGION" --profile "$AWS_PROFILE" --query 'containerServices[0].currentDeployment.state' --output text)
    if [ "$DEPLOYMENT_STATE" = "ACTIVE" ]; then
        echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
        break
    fi
    echo -n "."
    sleep 5
done
echo ""

# Step 8: Get service URL
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🎉 Deployment Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

SERVICE_URL=$(aws lightsail get-container-services --service-name "$SERVICE_NAME" --region "$REGION" --profile "$AWS_PROFILE" --query 'containerServices[0].url' --output text)

echo -e "${GREEN}Your KRAM API is now live at:${NC}"
echo -e "${BLUE}$SERVICE_URL${NC}"
echo ""
echo -e "${GREEN}Health check:${NC}"
echo -e "${BLUE}$SERVICE_URL/health${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Test your API: curl $SERVICE_URL/health"
echo "2. Update your frontend to use this URL"
echo "3. Update your custom domain (api.kramedu.in)"
echo ""
echo -e "${GREEN}Monthly cost: ~\$10-22 (vs \$50-100 on EB)${NC}"
echo -e "${GREEN}Annual savings: \$500-1,000 💰${NC}"
echo ""

# Cleanup
rm -f deployment.json

echo -e "${GREEN}✅ All done!${NC}"

