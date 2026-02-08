# 🚀 KRAM API - AWS Lightsail + CloudFront Deployment Guide

## 📋 Overview

KRAM backend is deployed on **AWS Lightsail Containers** with **CloudFront CDN** for custom domains.

**Service Name:** kram  
**Region:** ap-south-1 (Mumbai)  
**Monthly Cost:** $22-25 (vs $50-100 on EB)  
**Annual Savings:** $200-240 💰

---

## ✅ Prerequisites

### 1. AWS CLI Installed

```bash
# Check if installed
aws --version

# If not installed:
# macOS:
brew install awscli

# Or download from:
# https://aws.amazon.com/cli/
```

### 2. AWS Credentials Configured

```bash
# Configure AWS credentials for "kram" profile
aws configure --profile kram

# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: ap-south-1 (Mumbai)
# - Default output format: json
```

### 3. Docker Installed

```bash
# Check if installed
docker --version

# If not installed:
# macOS: Download Docker Desktop or OrbStack
# https://www.docker.com/products/docker-desktop
# https://orbstack.dev/
```

### 4. Lightsail Control Plugin

```bash
# Download and install lightsailctl
curl "https://s3.us-west-2.amazonaws.com/lightsailctl/latest/darwin-amd64/lightsailctl" -o lightsailctl

# Move to /usr/local/bin
mv lightsailctl /usr/local/bin/

# Make executable
chmod +x /usr/local/bin/lightsailctl

# Verify installation
lightsailctl version
```

---

## 🚀 Deployment

### Deploy to Lightsail

```bash
cd /Users/namitthakral/ed-verse/backend

# Run the automated deployment script
./scripts/lightsail-deploy.sh
```

The script will:
1. ✅ **Check Flutter frontend for changes** (automatic!)
2. ✅ **Rebuild Flutter web if needed** (automatic!)
3. ✅ Build Docker image for linux/amd64
4. ✅ Create/update Lightsail container service
5. ✅ Push image to Lightsail
6. ✅ Deploy with environment variables
7. ✅ **Run database migrations automatically**
8. ✅ Wait for deployment to complete
9. ✅ Show you the live URL

**Time:** 
- First deployment: 8-12 minutes
- Updates (backend only): 3-5 minutes  
- Updates (with frontend changes): 5-8 minutes

---

## 🗄️ Database Migrations (Automatic!)

### How It Works

Every time the container deploys or restarts, it **automatically runs database migrations** via a dedicated entrypoint script.

The container startup process:
1. ✅ Checks DATABASE_URL is set
2. ✅ Runs `npx prisma migrate deploy`
3. ✅ Verifies migration status
4. ✅ **Fails immediately** if migrations fail
5. ✅ Starts NestJS application only if migrations succeed

This is configured in `scripts/docker-entrypoint.sh` and called from the `Dockerfile`:

```dockerfile
ENTRYPOINT ["/app/docker-entrypoint.sh"]
```

**Key Benefit:** The container will **fail to start** if migrations fail, making issues visible immediately in logs!

### What This Means

✅ **New table changes?** Just deploy - migrations run automatically!  
✅ **Schema updates?** Deploy and they're applied!  
✅ **Zero manual intervention** needed!

### Manual Migration Check (Optional)

If you want to verify migrations manually:

```bash
# Check migration status
DATABASE_URL="postgresql://postgres:postgres@kram-db.chu82aoyy194.ap-south-1.rds.amazonaws.com:5432/postgres" \
npx prisma migrate status

# Or run migrations manually (usually not needed)
DATABASE_URL="postgresql://postgres:postgres@kram-db.chu82aoyy194.ap-south-1.rds.amazonaws.com:5432/postgres" \
npx prisma migrate deploy
```

---

## 🌐 Custom Domain Setup (CloudFront)

Your custom domains are configured via **AWS CloudFront CDN**:

### Current Setup

- **API Domain:** `api.kramedu.in` → CloudFront → Lightsail
- **Dashboard Domain:** `dashboard.kramedu.in` → CloudFront → Lightsail

### Architecture

```
User → Cloudflare DNS (DNS only)
     → CloudFront (SSL termination, caching)
     → Lightsail Container (kram.0665rbntwcxp6.ap-south-1.cs.amazonlightsail.com)
```

### CloudFront Distribution Details

- **Distribution ID:** E36FPX6Q6TAGJV
- **SSL Certificate:** Free via AWS Certificate Manager (ACM)
- **Region:** us-east-1 (required for CloudFront)
- **Caching:** Disabled for API (all requests forwarded)
- **HTTP → HTTPS:** Automatic redirect enabled

### Cloudflare Configuration

⚠️ **Important:** Cloudflare proxy must be **OFF** (DNS only, gray cloud) for CloudFront domains!

**DNS Records:**
```
api.kramedu.in       CNAME  d36wpobhvniwla.cloudfront.net  (DNS only)
dashboard.kramedu.in CNAME  d36wpobhvniwla.cloudfront.net  (DNS only)
```

**SSL/TLS Mode:** Full (strict)

### Adding New Custom Domains

If you need to add more domains:

1. **Add domain to ACM certificate** (us-east-1):
```bash
aws acm request-certificate \
  --domain-name new.kramedu.in \
  --validation-method DNS \
  --region us-east-1 \
  --profile kram
```

2. **Validate with DNS records** (add to Cloudflare)

3. **Update CloudFront alternate domains:**
```bash
# Get current config
aws cloudfront get-distribution-config \
  --id E36FPX6Q6TAGJV \
  --profile kram > cf-config.json

# Edit cf-config.json to add new domain
# Then update:
aws cloudfront update-distribution \
  --id E36FPX6Q6TAGJV \
  --if-match <ETag-from-get-command> \
  --distribution-config file://cf-config.json \
  --profile kram
```

4. **Add CNAME in Cloudflare** (DNS only)

---

## 🔍 Testing Your Deployment

### Test Health Endpoint

```bash
# Via custom domain
curl https://api.kramedu.in/health

# Via Lightsail URL (also works)
curl https://kram.0665rbntwcxp6.ap-south-1.cs.amazonlightsail.com/health
```

Expected response:
```json
{
  "status": "OK",
  "timestamp": "2026-02-05T...",
  "service": "ed-verse-backend",
  "version": "1.0.0",
  "environment": "production"
}
```

### Test Dashboard

```bash
# Open in browser
open https://dashboard.kramedu.in
```

### Test SSL

```bash
# Check SSL certificate
curl -vI https://api.kramedu.in 2>&1 | grep -E "subject:|issuer:"

# Verify HTTP → HTTPS redirect
curl -I http://api.kramedu.in
```

---

## 🔧 Database Configuration

### RDS Security Group

Your RDS database (`kram-db`) is configured to allow connections from Lightsail:

- **Security Group:** sg-0fe7983421d6f37c2
- **Inbound Rule:** PostgreSQL (5432) from 0.0.0.0/0

**Note:** For production, restrict this to Lightsail VPC only.

### Connection String

```
postgresql://postgres:postgres@kram-db.chu82aoyy194.ap-south-1.rds.amazonaws.com:5432/postgres
```

This is already configured in `lightsail-deploy.sh` and deployed to the container.

---

## 📊 Monitoring & Logs

### View Logs

```bash
# View container logs
aws lightsail get-container-log \
  --service-name kram \
  --container-name app \
  --region ap-south-1 \
  --profile kram

# Follow logs (last 50 lines)
aws lightsail get-container-log \
  --service-name kram \
  --container-name app \
  --region ap-south-1 \
  --profile kram \
  --page-size 50
```

### View Service Status

```bash
# Get service state
aws lightsail get-container-services \
  --service-name kram \
  --region ap-south-1 \
  --profile kram \
  --query 'containerServices[0].state' \
  --output text

# Get deployment state
aws lightsail get-container-services \
  --service-name kram \
  --region ap-south-1 \
  --profile kram \
  --query 'containerServices[0].currentDeployment.state' \
  --output text
```

### AWS Console

View in browser:
- **Lightsail:** https://lightsail.aws.amazon.com/ls/webapp/ap-south-1/container-services/kram
- **CloudFront:** https://console.aws.amazon.com/cloudfront/v3/home#/distributions/E36FPX6Q6TAGJV
- **RDS:** https://ap-south-1.console.aws.amazon.com/rds/home?region=ap-south-1#database:id=kram-db

---

## 🔄 Updating Your Application

### Quick Update (Recommended)

```bash
cd /Users/namitthakral/ed-verse/backend

# Make your code changes (backend OR frontend), then:
./scripts/lightsail-deploy.sh
```

This will **automatically**:
1. ✅ Check if Flutter frontend changed
2. ✅ Rebuild Flutter web if needed (skipped if no changes)
3. ✅ Build new Docker image with latest code
4. ✅ Push to Lightsail
5. ✅ Deploy new version
6. ✅ **Run database migrations**
7. ✅ Restart container with new code

**The script is smart!** It detects:
- Frontend changes in `../frontend/lib/**/*.dart`
- Compares with last dashboard build time
- Automatically rebuilds only when needed
- Shows you when rebuilding happens

### Frontend-Only Updates

If you only changed the Flutter frontend:

```bash
cd /Users/namitthakral/ed-verse/backend

# The script will detect frontend changes and rebuild automatically
./scripts/lightsail-deploy.sh
```

**What you'll see:**
```
📱 Checking Flutter Frontend
⚠️  Frontend code changed since last build
   Frontend modified: 2026-02-08 11:30:00
   Dashboard built: 2026-01-27 12:46:00

🔨 Rebuilding Flutter web app...
✅ Flutter build successful
📦 Copying Flutter build to backend...
✅ Dashboard updated
```

### Backend-Only Updates

If you only changed backend code:

```bash
cd /Users/namitthakral/ed-verse/backend

# The script will skip frontend rebuild
./scripts/lightsail-deploy.sh
```

**What you'll see:**
```
📱 Checking Flutter Frontend
✅ Dashboard is up to date
```

### Manual Update (If needed)

```bash
# 1. Build new image
docker build --platform linux/amd64 -t kram:latest .

# 2. Push to Lightsail
aws lightsail push-container-image \
  --service-name kram \
  --label kram \
  --image kram:latest \
  --region ap-south-1 \
  --profile kram

# 3. Get new image name
IMAGE_NAME=$(aws lightsail get-container-images \
  --service-name kram \
  --region ap-south-1 \
  --profile kram \
  --query 'containerImages[0].image' \
  --output text)

# 4. Create deployment JSON with new image name
# (Update deployment.json with new IMAGE_NAME)

# 5. Deploy
aws lightsail create-container-service-deployment \
  --region ap-south-1 \
  --profile kram \
  --cli-input-json file://deployment.json
```

---

## ⚖️ Scaling Your Service

### Vertical Scaling (More Power)

```bash
# Upgrade to 'small' (1 vCPU, 2 GB RAM - $20/month)
aws lightsail update-container-service \
  --service-name kram \
  --power small \
  --region ap-south-1 \
  --profile kram
```

**Power Options:**
- `nano`: 0.25 vCPU, 512 MB RAM - $7/month
- `micro`: 0.5 vCPU, 1 GB RAM - $10/month (current)
- `small`: 1 vCPU, 2 GB RAM - $20/month
- `medium`: 2 vCPU, 4 GB RAM - $40/month
- `large`: 4 vCPU, 8 GB RAM - $80/month

### Horizontal Scaling (More Instances)

```bash
# Scale to 2 instances
aws lightsail update-container-service \
  --service-name kram \
  --scale 2 \
  --region ap-south-1 \
  --profile kram
```

**Cost:** Each instance costs the same as the power level
- 2 × micro = $20/month
- 2 × small = $40/month

---

## 🚨 Troubleshooting

### Container Won't Start

```bash
# Check logs for errors
aws lightsail get-container-log \
  --service-name kram \
  --container-name app \
  --region ap-south-1 \
  --profile kram | less

# Common issues:
# - Database connection failed → Check RDS security group
# - Migration failed → Check database permissions
# - Port binding failed → Check PORT env var
```

### Database Connection Issues

```bash
# Test database connection from local machine
psql "postgresql://postgres:postgres@kram-db.chu82aoyy194.ap-south-1.rds.amazonaws.com:5432/postgres"

# Check RDS security group allows inbound on 5432
# Security Group: sg-0fe7983421d6f37c2
```

### Deployment Stuck

```bash
# Check deployment state
aws lightsail get-container-services \
  --service-name kram \
  --region ap-south-1 \
  --profile kram

# If stuck, force redeploy
./scripts/lightsail-deploy.sh
```

### Frontend Not Updating

**Issue:** Made UI changes but still seeing old dashboard

**Causes:**
1. Flutter web wasn't rebuilt
2. CloudFront cache serving old files

**Solution:**
```bash
# 1. Redeploy (will auto-rebuild frontend)
cd /Users/namitthakral/ed-verse/backend
./scripts/lightsail-deploy.sh

# 2. Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id E36FPX6Q6TAGJV \
  --paths "/*" \
  --profile kram

# 3. Hard refresh browser (Cmd + Shift + R)
```

**Manual Flutter rebuild:**
```bash
# If auto-rebuild fails
cd /Users/namitthakral/ed-verse/frontend
flutter build web --release
cp -r build/web/* ../backend/public/dashboard/

# Then deploy
cd ../backend
./scripts/lightsail-deploy.sh
```

### Custom Domain Not Working

1. **Check CloudFront status:**
```bash
aws cloudfront get-distribution \
  --id E36FPX6Q6TAGJV \
  --profile kram \
  --query 'Distribution.Status'
```

2. **Verify DNS records:**
```bash
dig api.kramedu.in
dig dashboard.kramedu.in
```

3. **Check Cloudflare proxy:** Must be OFF (gray cloud) for CloudFront

4. **Test direct Lightsail URL:**
```bash
curl https://kram.0665rbntwcxp6.ap-south-1.cs.amazonlightsail.com/health
```

### SSL Certificate Issues

```bash
# Check ACM certificate status
aws acm list-certificates \
  --region us-east-1 \
  --profile kram

# View certificate details
aws acm describe-certificate \
  --certificate-arn <arn> \
  --region us-east-1 \
  --profile kram
```

### Out of Memory

```bash
# Check container metrics
aws lightsail get-container-service-metric-data \
  --service-name kram \
  --metric-name MemoryUtilization \
  --start-time $(date -u -v-1H +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average \
  --region ap-south-1 \
  --profile kram

# If consistently high, upgrade power
aws lightsail update-container-service \
  --service-name kram \
  --power small \
  --region ap-south-1 \
  --profile kram
```

---

## 🗑️ Deleting Resources

### Delete Container Service

```bash
aws lightsail delete-container-service \
  --service-name kram \
  --region ap-south-1 \
  --profile kram
```

### Delete CloudFront Distribution

```bash
# 1. Disable distribution first
aws cloudfront get-distribution-config \
  --id E36FPX6Q6TAGJV \
  --profile kram > cf-config.json

# Edit cf-config.json and set "Enabled": false

aws cloudfront update-distribution \
  --id E36FPX6Q6TAGJV \
  --if-match <ETag> \
  --distribution-config file://cf-config.json \
  --profile kram

# 2. Wait for deployment (5-10 minutes)

# 3. Delete
aws cloudfront delete-distribution \
  --id E36FPX6Q6TAGJV \
  --if-match <new-ETag> \
  --profile kram
```

### Delete RDS Database

```bash
# Create final snapshot
aws rds delete-db-instance \
  --db-instance-identifier kram-db \
  --final-db-snapshot-identifier kram-db-final-snapshot \
  --region ap-south-1 \
  --profile kram

# Or skip snapshot (not recommended)
aws rds delete-db-instance \
  --db-instance-identifier kram-db \
  --skip-final-snapshot \
  --region ap-south-1 \
  --profile kram
```

---

## 💰 Cost Breakdown

### Current Production Setup

```
Lightsail Container (micro):  $10/month
RDS Database (t3.micro):      $15/month
CloudFront:                   $0-2/month (free tier)
Data Transfer:                $0 (included)
ACM SSL Certificate:          $0 (free)
────────────────────────────────────────
Total:                        $25-27/month
Annual:                       $300-324/year
```

### Previous Setup (Elastic Beanstalk)

```
EC2 Instance (t3.small):      $30/month
Load Balancer:                $16/month
RDS Database (t3.micro):      $15/month
CloudWatch:                   $5/month
────────────────────────────────────────
Total:                        $66/month
Annual:                       $792/year
```

**Annual Savings: $240-270** 🎉

### Free Tier Benefits

- **Lightsail:** First 3 months free (up to $50/month)
- **CloudFront:** 1 TB data transfer free (permanent)
- **ACM:** Free SSL certificates (permanent)

---

## 📞 Support & Resources

### AWS Documentation
- **Lightsail Containers:** https://docs.aws.amazon.com/lightsail/latest/userguide/amazon-lightsail-containers.html
- **CloudFront:** https://docs.aws.amazon.com/cloudfront/
- **ACM:** https://docs.aws.amazon.com/acm/

### AWS CLI Reference
- **Lightsail:** https://docs.aws.amazon.com/cli/latest/reference/lightsail/
- **CloudFront:** https://docs.aws.amazon.com/cli/latest/reference/cloudfront/

### Docker
- **Multi-stage builds:** https://docs.docker.com/build/building/multi-stage/
- **Best practices:** https://docs.docker.com/develop/dev-best-practices/

### Prisma
- **Migrations:** https://www.prisma.io/docs/concepts/components/prisma-migrate
- **Deployment:** https://www.prisma.io/docs/guides/deployment

---

## ✅ Production Checklist

Before going live:

- [x] Lightsail container service created and deployed
- [x] Database migrations automated in Dockerfile
- [x] RDS security group configured
- [x] Custom domains configured via CloudFront
- [x] SSL certificates validated and active
- [x] HTTP → HTTPS redirect enabled
- [x] Health checks configured
- [x] Logging accessible via AWS CLI
- [ ] Monitor application for 24-48 hours
- [ ] Set up CloudWatch alarms (optional)
- [ ] Configure automated backups for RDS
- [ ] Document rollback procedure
- [ ] Test disaster recovery

---

**Last Updated:** February 5, 2026  
**Deployment Platform:** AWS Lightsail + CloudFront  
**Service Name:** kram  
**Monthly Cost:** $25-27 (vs $66 on EB)  
**Status:** ✅ Production Ready

---

## 🚀 Quick Reference Commands

```bash
# Deploy/Update
./scripts/lightsail-deploy.sh

# View logs
aws lightsail get-container-log --service-name kram --container-name app --region ap-south-1 --profile kram

# Check status
aws lightsail get-container-services --service-name kram --region ap-south-1 --profile kram

# Test health
curl https://api.kramedu.in/health

# Scale up
aws lightsail update-container-service --service-name kram --power small --region ap-south-1 --profile kram
```

---

🎉 **Happy Deploying!**
