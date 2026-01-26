# AWS Elastic Beanstalk Deployment Guide

This guide documents the complete setup for deploying the Ed-Verse application (NestJS backend + Flutter web frontend) to AWS Elastic Beanstalk.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Structure Changes](#project-structure-changes)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Deployment Steps](#deployment-steps)
6. [Access Points](#access-points)
7. [Troubleshooting](#troubleshooting)
8. [Future Deployments](#future-deployments)

---

## Prerequisites

- AWS Account with appropriate permissions
- AWS Access Key ID and Secret Access Key
- Node.js 18+ installed locally
- Flutter SDK installed locally
- Git installed

---

## Project Structure Changes

The following files were added/modified for AWS deployment:

```
ed-verse/
├── AWS_DEPLOYMENT_GUIDE.md          # This file
├── scripts/
│   └── build-frontend.sh            # Flutter web build script
├── package.json                     # Added build:deploy script
├── backend/
│   ├── .ebextensions/
│   │   └── 01_npm.config            # Forces npm install on EB
│   ├── .ebignore                    # Files to exclude from deployment
│   ├── .elasticbeanstalk/
│   │   └── config.yml               # EB configuration (auto-generated)
│   ├── public/
│   │   └── dashboard/               # Flutter web build output
│   ├── src/
│   │   └── app.module.ts            # Added ServeStaticModule
│   └── package.json                 # Added start:prod, dependencies
└── frontend/
    └── web/
        └── index.html               # Updated base href placeholder
```

### Key File Changes

#### 1. `backend/src/app.module.ts`
Added ServeStaticModule to serve Flutter web app at `/dashboard`:

```typescript
import { ServeStaticModule } from '@nestjs/serve-static'
import { join } from 'path'

@Module({
  imports: [
    // Serve Flutter web app at /dashboard
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', '..', 'public', 'dashboard'),
      serveRoot: '/dashboard',
      serveStaticOptions: {
        index: ['index.html'],
        fallthrough: false,
      },
    }),
    // ... other modules
  ],
})
```

#### 2. `backend/package.json`
Added production start script and @nestjs/serve-static dependency:

```json
{
  "scripts": {
    "start:prod": "node dist/src/main"
  },
  "dependencies": {
    "@nestjs/serve-static": "^4.0.2"
  }
}
```

#### 3. `backend/.ebextensions/01_npm.config`
Forces npm install on Elastic Beanstalk:

```yaml
container_commands:
  01_npm_install:
    command: "npm install --omit=dev"
    cwd: "/var/app/staging"
    ignoreErrors: false
```

#### 4. `backend/.ebignore`
Excludes unnecessary files from deployment:

```
node_modules/
.env
.env.local
.env.*.local
.git/
*.log
*.spec.ts
test/
*.md
!README.md
```

#### 5. `scripts/build-frontend.sh`
Builds Flutter web app with correct base-href:

```bash
#!/bin/bash
set -e
cd frontend
flutter pub get
flutter build web --release --base-href "/dashboard/"
cp -r build/web/* ../backend/public/dashboard/
```

#### 6. `frontend/web/index.html`
Updated base href placeholder:

```html
<base href="$FLUTTER_BASE_HREF">
```

---

## Installation

### Step 1: Install AWS CLI

```bash
# macOS (using Homebrew)
brew install awscli

# Verify installation
aws --version
```

### Step 2: Install EB CLI

```bash
# macOS (using Homebrew)
brew install awsebcli

# Verify installation
eb --version
```

### Step 3: Configure AWS Credentials

```bash
aws configure --profile kram
```

Enter when prompted:
- **AWS Access Key ID**: Your access key
- **AWS Secret Access Key**: Your secret key
- **Default region**: `ap-south-1`
- **Default output format**: `json`

Verify configuration:
```bash
aws sts get-caller-identity --profile kram
```

---

## Configuration

### Step 1: Initialize EB Application

```bash
cd backend

# Set AWS credentials
export AWS_PROFILE=kram

# Initialize EB application
eb init ed-verse-backend \
  --platform "Node.js 20 running on 64bit Amazon Linux 2023" \
  --region ap-south-1
```

### Step 2: Create RDS Database (if not already created)

Create a PostgreSQL RDS instance in the AWS Console:
- **Engine**: PostgreSQL
- **Instance class**: db.t4g.micro (free tier)
- **Region**: ap-south-1
- **Database name**: postgres
- **Master username**: postgres
- **Master password**: (your secure password)

Note the RDS endpoint: `your-db.xxxxxx.ap-south-1.rds.amazonaws.com`

Note the RDS endpoint: `your-db.xxxxxx.ap-south-1.rds.amazonaws.com`

---

## CloudFront & SSL Setup (Required for Production)

To serve the application with HTTPS and a custom domain (`dashboard.kramedu.in`), we use AWS CloudFront in front of Elastic Beanstalk.

### 1. Request Certificate (ACM)
**Region: US East (N. Virginia) - us-east-1** (CRITICAL: Must be us-east-1 for CloudFront)
1. Request public certificate for `dashboard.kramedu.in`.
2. Validate via DNS (Route 53).

### 2. Create CloudFront Distribution
1. **Origin Domain**: Your Elastic Beanstalk URL.
2. **Protocol**: HTTP Only (CloudFront -> EB).
3. **Viewer Protocol**: Redirect HTTP to HTTPS.
4. **Allowed Methods**: GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE.
5. **Cache Policy**: `CachingDisabled` (to prevent stale API/App data).
6. **Alternate Domain Name**: `dashboard.kramedu.in`.
7. **Custom SSL Certificate**: Select the ACM certificate created above.

### 3. Configure DNS (Route 53)
1. Create/Edit `dashboard.kramedu.in` A record.
2. Enable **Alias**.
3. Route to **CloudFront Distribution**.

---

## Deployment Steps

### Step 1: Build Flutter Frontend

```bash
# From project root
npm run build:frontend:deploy

# Or manually
cd frontend
flutter pub get
flutter build web --release --base-href "/dashboard/"
mkdir -p ../backend/public/dashboard
cp -r build/web/* ../backend/public/dashboard/
```

### Step 2: Build NestJS Backend

```bash
cd backend
npm run build
```

### Step 3: Create EB Environment

```bash
cd backend
export AWS_PROFILE=kram

# Create environment with t3.small instance
eb create ed-verse-api --instance-type t3.small --single --timeout 20
```

### Step 4: Configure Security Groups

Get the EB security group ID:
```bash
aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=*awseb-e-*" \
  --query "SecurityGroups[*].GroupId" \
  --output text \
  --profile kram
```

Add EB security group to RDS inbound rules:
```bash
aws ec2 authorize-security-group-ingress \
  --group-id <RDS_SECURITY_GROUP_ID> \
  --protocol tcp \
  --port 5432 \
  --source-group <EB_SECURITY_GROUP_ID> \
  --profile kram
```

### Step 5: Set Environment Variables

```bash
eb setenv \
  DATABASE_URL="postgresql://postgres:PASSWORD@your-db.xxxxxx.ap-south-1.rds.amazonaws.com:5432/postgres" \
  JWT_SECRET="your-jwt-secret-key" \
  JWT_REFRESH_SECRET="your-refresh-secret-key" \
  NODE_ENV="production"
```

### Step 6: Deploy

```bash
eb deploy
```

### Step 7: Verify Deployment

```bash
# Check status
eb status

# Check health
curl http://your-env.elasticbeanstalk.com/health

# Check dashboard
curl -I http://your-env.elasticbeanstalk.com/dashboard/
```

---

## Access Points

After successful deployment, your application will be accessible at:

| Endpoint | URL |
|----------|-----|
| **Dashboard (CloudFront)** | `https://dashboard.kramedu.in` |
| **API (Direct EB)** | `http://ed-verse-api.eba-dx3z9kvh.ap-south-1.elasticbeanstalk.com/api` |
| **Health Check** | `http://ed-verse-api.eba-dx3z9kvh.ap-south-1.elasticbeanstalk.com/health` |
| **API Docs** | `http://ed-verse-api.eba-dx3z9kvh.ap-south-1.elasticbeanstalk.com/api/docs` |

> **Note**: The Dashboard is served via HTTPS through CloudFront. The API is accessed directly or via CloudFront depending on the configuration, but for this setup, the Flutter app accesses the API via the EB URL (or CloudFront if `/api` behavior is configured).

---

## Troubleshooting

### Issue: Health Status Red

**Check logs:**
```bash
eb logs
```

**Common causes:**
1. Database connection failed - check security groups
2. Environment variables not set
3. npm install failed

### Issue: Dashboard Returns 404

**Cause:** Flutter web build not included in deployment

**Fix:**
```bash
npm run build:frontend:deploy
cd backend && npm run build
eb deploy
```

### Issue: Cannot Find Module

**Cause:** npm install didn't run on EB

**Fix:** Ensure `.ebextensions/01_npm.config` exists with:
```yaml
container_commands:
  01_npm_install:
    command: "npm install --omit=dev"
    cwd: "/var/app/staging"
    ignoreErrors: false
```

### Issue: Database Connection Timeout

**Cause:** Security groups not configured

**Fix:** Add EB security group to RDS inbound rules (see Step 4 above)

### View Detailed Logs

```bash
# Tail logs
eb logs

# Full bundle logs
eb logs --all

# SSH into instance (if enabled)
eb ssh
```

---

## Future Deployments

### Quick Deploy (After Code Changes)

```bash
# 1. Build frontend (if changed)
npm run build:frontend:deploy

# 2. Build backend
cd backend && npm run build

# 3. Deploy
eb deploy
```

### One-Command Deploy

From project root:
```bash
npm run build:deploy && cd backend && eb deploy
```

### Useful EB Commands

```bash
# Check environment status
eb status

# View logs
eb logs

# Open in browser
eb open

# List environments
eb list

# Terminate environment
eb terminate ed-verse-api

# SSH into instance
eb ssh

# View environment variables
eb printenv
```

---

## Environment Details

| Setting | Value |
|---------|-------|
| **Platform** | Node.js 20 on Amazon Linux 2023 |
| **Instance Type** | t3.small |
| **Region** | ap-south-1 (Mumbai) |
| **Database** | PostgreSQL (RDS) |
| **Application Name** | ed-verse-backend |
| **Environment Name** | ed-verse-api |

---

## Cost Considerations

- **t3.small**: ~$15-20/month (on-demand)
- **RDS db.t4g.micro**: Free tier eligible for 12 months
- **Data transfer**: Varies by usage

To reduce costs:
- Use reserved instances for production
- Enable auto-scaling based on load
- Use Spot instances for non-production

---

## Security Recommendations

1. **Use HTTPS**: Configure SSL certificate via AWS Certificate Manager
2. **Restrict Security Groups**: Only allow necessary inbound traffic
3. **Rotate Secrets**: Regularly rotate JWT secrets and database passwords
4. **Enable Logging**: Configure CloudWatch logs for monitoring
5. **Use IAM Roles**: Don't embed credentials in code

---

*Last updated: January 25, 2026*
