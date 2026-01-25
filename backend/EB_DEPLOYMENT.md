# Elastic Beanstalk Deployment Guide

This guide walks you through deploying the Kram backend to AWS Elastic Beanstalk.

## Prerequisites

1. **AWS Account** with appropriate credits/permissions
2. **AWS CLI** installed and configured
3. **EB CLI** installed (`pip install awsebcli`)
4. **PostgreSQL RDS Instance** created and running
5. **AWS Profile** configured for this project

## Part 1: Pre-Deployment Setup

### 1.1 Configure AWS Profile

```bash
# Create a dedicated AWS profile for Kram
aws configure --profile kram

# Enter your AWS credentials when prompted:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: ap-south-1
# - Default output format: json

# Set the profile for your terminal session
export AWS_PROFILE=kram
```

### 1.2 Verify RDS Database

Ensure your RDS instance is running and accessible:
- **Endpoint**: `kram-db.chu82aoyy194.ap-south-1.rds.amazonaws.com`
- **Port**: `5432`
- **Database**: `postgres`
- **Username**: `postgres`
- **Password**: `postgres`

### 1.3 Prepare Environment Variables

You'll need these values:
```bash
DATABASE_URL="postgresql://postgres:postgres@kram-db.chu82aoyy194.ap-south-1.rds.amazonaws.com:5432/postgres"
JWT_SECRET="kLwCEfoXnjyHVsjQi+BdIB5EOE35DOiYXzeT9oNYAcLbom/vt+qLaGrk0SDaSAfW"
NODE_ENV="production"
```

## Part 2: Build Flutter Frontend for Web

The Flutter frontend is served from the backend at `/dashboard`. Before deploying, you must build the Flutter web app.

### 2.1 Build Flutter Web App

From the **project root** directory:

```bash
# Build Flutter web and copy to backend/public/dashboard
npm run build:frontend:deploy

# Or run the script directly
./scripts/build-frontend.sh
```

This script will:
1. Build the Flutter web app with `--base-href "/dashboard/"`
2. Copy the build output to `backend/public/dashboard/`

### 2.2 Verify the Build

After building, you should have files in `backend/public/dashboard/`:
```bash
ls backend/public/dashboard/
# Should show: index.html, main.dart.js, flutter.js, assets/, etc.
```

## Part 3: Configure Backend for EB

### 3.1 Update `package.json`

Ensure Prisma is in **dependencies** (not devDependencies):

```json
{
  "dependencies": {
    "prisma": "^6.19.0",
    "@prisma/client": "^6.19.0",
    "@nestjs/serve-static": "^4.0.2"
  },
  "scripts": {
    "build": "npm run build:schema && npx prisma generate && nest build",
    "start:prod": "node dist/main"
  }
}
```

### 3.2 Create/Verify `Procfile`

```
web: npm run start:prod
```

### 3.3 Create `.ebignore`

```
node_modules/
.env
.git/
*.log
dist/
.env.local
.env.*.local
```

### 3.4 Update `src/main.ts` - CORS Configuration

Ensure your app listens on all interfaces and includes the EB URL in CORS:

```typescript
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS
  app.enableCors({
    origin: [
      'http://localhost:3000',
      /^http:\/\/localhost:\d+$/,
      /^http:\/\/127\.0\.0\.1:\d+$/,
      'http://kram-backend-v3.eba-jmwz47my.ap-south-1.elasticbeanstalk.com',
      'https://kram-backend-v3.eba-jmwz47my.ap-south-1.elasticbeanstalk.com',
    ],
    credentials: true,
  });

  const port = process.env.PORT || 3000;
  await app.listen(port, '0.0.0.0'); // Listen on all interfaces
  console.log(`🚀 Kram backend running on port ${port}`);
}
```

## Part 4: Deploy to Elastic Beanstalk

### 4.1 Initialize EB Application

```bash
cd /path/to/ed-verse/backend
export AWS_PROFILE=kram

# Initialize EB
eb init

# When prompted:
# - Select region: ap-south-1 (Mumbai)
# - Create new application: kram-backend
# - Platform: Node.js
# - Platform version: Node.js 20 running on 64bit Amazon Linux 2023
# - SSH: No (unless you need debugging access)
```

### 4.2 Create Environment

```bash
# Create a new environment
eb create kram-backend-prod \
  --instance-type t3.micro \
  --platform "Node.js 20 running on 64bit Amazon Linux 2023" \
  --timeout 20

# This will take 5-10 minutes
# Wait for "Successfully launched environment" message
```

### 4.3 Set Environment Variables

Once the environment is created and **Status is Ready**:

```bash
eb setenv \
  DATABASE_URL="postgresql://postgres:postgres@kram-db.chu82aoyy194.ap-south-1.rds.amazonaws.com:5432/postgres" \
  JWT_SECRET="kLwCEfoXnjyHVsjQi+BdIB5EOE35DOiYXzeT9oNYAcLbom/vt+qLaGrk0SDaSAfW" \
  NODE_ENV="production"

# This will restart the environment (takes ~5 minutes)
```

### 4.4 Configure Security Groups for RDS Access

Your EB instances need permission to connect to RDS.

```bash
# 1. Get the EB security group ID
eb events | grep "Created security group"
# Note the security group name (e.g., awseb-e-xxxxx-stack-AWSEBSecurityGroup-xxxxx)

# 2. Get the actual security group ID
aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=awseb-e-xxxxx-stack-AWSEBSecurityGroup-xxxxx" \
  --query "SecurityGroups[0].GroupId" \
  --output text

# 3. Get your RDS security group ID
aws rds describe-db-instances \
  --db-instance-identifier kram-db \
  --query "DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId" \
  --output text

# 4. Add EB security group to RDS inbound rules
aws ec2 authorize-security-group-ingress \
  --group-id <RDS_SECURITY_GROUP_ID> \
  --protocol tcp \
  --port 5432 \
  --source-group <EB_SECURITY_GROUP_ID>
```

## Part 5: Run Database Migrations

### 5.1 Option A: SSH into EB Instance (if SSH enabled)

```bash
eb ssh

# Once connected:
cd /var/app/current
npm run build:schema
npx prisma generate
npx prisma migrate deploy
npx prisma db seed  # If you have seed data
exit
```

### 5.2 Option B: Run Migrations Locally (Temporary)

```bash
# In your local backend directory
export DATABASE_URL="postgresql://postgres:postgres@kram-db.chu82aoyy194.ap-south-1.rds.amazonaws.com:5432/postgres"
npm run build:schema
npx prisma migrate deploy
npx prisma db seed  # If you have seed data
```

## Part 6: Verify Deployment

### 6.1 Check Environment Status

```bash
eb status

# Should show:
# - Status: Ready
# - Health: Ok or Green
```

### 6.2 View Application Logs

```bash
# Stream logs in real-time
eb logs --stream

# Or get recent logs
eb logs
```

### 6.3 Test the API and Dashboard

```bash
# Get your environment URL
eb status | grep CNAME

# Test health endpoint
curl http://your-environment.elasticbeanstalk.com/health

# Test API
curl http://your-environment.elasticbeanstalk.com/api/v1/auth/health

# Access Flutter Dashboard
# Open in browser: http://your-environment.elasticbeanstalk.com/dashboard
```

## Part 7: Common Commands

### Deployment

```bash
# Deploy updated code
eb deploy

# Deploy with custom timeout
eb deploy --timeout 20
```

### Monitoring

```bash
# Check environment status
eb status

# View recent events
eb events

# Follow events in real-time
eb events --follow

# View application logs
eb logs

# Stream logs
eb logs --stream
```

### Environment Management

```bash
# List all environments
eb list

# Use a specific environment
eb use kram-backend-prod

# Restart the environment
eb restart

# Open environment in browser
eb open

# SSH into instance (if enabled)
eb ssh
```

### Configuration

```bash
# View environment variables
eb printenv

# Set environment variables
eb setenv KEY1=value1 KEY2=value2

# Update configuration
eb config
```

### Cleanup

```bash
# Terminate environment (careful!)
eb terminate kram-backend-prod

# Delete application (after terminating all environments)
# This is done through AWS Console
```

## Part 8: Troubleshooting

### Issue: Health is Red / 5xx Errors

**Check logs:**
```bash
eb logs
```

**Common causes:**
1. Missing environment variables
2. Database connection issues (security groups)
3. Prisma client not generated
4. Port configuration (app must listen on `process.env.PORT`)

### Issue: Deployment Timeout

**Symptoms:** "Command execution completed on all instances. Summary: [Successful: 0, TimedOut: 1]"

**Solutions:**
1. Simplify Procfile (remove complex commands)
2. Move Prisma generation to build script
3. Use platform hooks for initialization

### Issue: Database Connection Refused

**Cause:** Security groups not configured

**Fix:**
```bash
# Add EB security group to RDS inbound rules (see Section 3.4)
```

### Issue: Prisma Client Not Generated

**Symptoms:** `Cannot find module '@prisma/client'`

**Fix:**
1. Ensure Prisma is in `dependencies` (not `devDependencies`)
2. Add `npx prisma generate` to build script
3. Run migrations on the instance

### Issue: Flutter Dashboard Not Loading

**Symptoms:** 404 error when accessing `/dashboard`

**Fix:**
1. Ensure you built the Flutter web app before deploying:
   ```bash
   npm run build:frontend:deploy
   ```
2. Verify `backend/public/dashboard/index.html` exists
3. Check that `public/` is NOT in `.ebignore`
4. Redeploy: `eb deploy`

### Issue: Flutter App Shows Blank Page

**Symptoms:** Dashboard loads but shows nothing

**Fix:**
1. Check browser console for errors
2. Ensure base-href is correct (`/dashboard/`)
3. Rebuild with correct base-href:
   ```bash
   cd frontend
   flutter build web --release --base-href "/dashboard/"
   ```

## Part 9: Best Practices

1. **Never commit `.env` files** - Use EB environment variables
2. **Always use a dedicated AWS profile** - Avoid mixing personal/work credentials
3. **Monitor costs** - Check AWS billing regularly (t3.micro + RDS can cost ~$20-30/month)
4. **Enable logs** - Keep CloudWatch logs enabled for debugging
5. **Use version control** - Tag releases before deployment
6. **Test locally first** - Always test with Docker or local setup
7. **Backup database** - Take RDS snapshots before major migrations

## Part 10: Cost Optimization

### Free Tier Eligible
- EC2 t3.micro (750 hours/month for 12 months)
- RDS db.t4g.micro (750 hours/month for 12 months)
- 20GB RDS storage

### After Free Tier
- **EB + EC2**: ~$8-15/month (t3.micro)
- **RDS**: ~$15-25/month (db.t4g.micro with 20GB storage)
- **Data Transfer**: Usually minimal for small apps

### To Minimize Costs
1. Use t3.micro or t4g.micro instances
2. Stop RDS when not in use (dev environments)
3. Use single-instance EB configuration
4. Monitor unused resources

## Support

For issues:
1. Check logs: `eb logs`
2. Check events: `eb events`
3. Check AWS Console for detailed errors
4. Review this guide's troubleshooting section

---

**Last Updated:** January 24, 2026  
**Environment:** Node.js 20, NestJS, PostgreSQL, Prisma

