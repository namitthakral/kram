# 🚀 GitHub Actions Deployment Guide

This repository uses GitHub Actions to automate deployments to AWS Lightsail.

## 📋 Setup Instructions

### 1. Configure GitHub Secrets

Go to your GitHub repository:
```
Settings → Secrets and variables → Actions → New repository secret
```

Add the following secrets:

| Secret Name | Description | Example Value |
|------------|-------------|---------------|
| `AWS_ACCESS_KEY_ID` | AWS access key for deployment | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret access key | `wJal...` |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/db` |
| `JWT_SECRET` | JWT signing secret | Your JWT secret key |
| `JWT_REFRESH_SECRET` | JWT refresh token secret | Your refresh secret key |

### 2. Deploy Using GitHub Actions

#### Manual Deployment (Recommended)

1. Go to your repository on GitHub
2. Click on **"Actions"** tab
3. Select **"Deploy to AWS Lightsail"** workflow
4. Click **"Run workflow"** button
5. Configure options:
   - **Skip frontend rebuild**: Check if you only changed backend code
   - **Invalidate CloudFront cache**: Uncheck if you don't need immediate updates
   - **Deployment reason**: Add a note (optional)
6. Click **"Run workflow"**

#### Monitor Deployment

- Watch the deployment progress in real-time
- Typical deployment time: 8-12 minutes
- You'll see:
  - Frontend build (if needed)
  - Docker image build
  - Push to Lightsail
  - Deployment status
  - Health check results

### 3. Verify Deployment

After deployment completes:

```bash
# Test API
curl https://api.kramedu.in/health

# Test Dashboard
open https://dashboard.kramedu.in
```

## 🎯 Deployment Options

### Skip Frontend Rebuild

Use this when:
- ✅ You only changed backend code
- ✅ You want faster deployments (3-5 min vs 8-12 min)
- ✅ Frontend was already built recently

### Invalidate CloudFront Cache

Use this when:
- ✅ You changed frontend/UI
- ✅ You need users to see changes immediately
- ✅ You updated static assets

Note: Cache invalidation takes 3-5 minutes to propagate globally.

## 📊 Deployment Status

Check deployment status in multiple ways:

### GitHub Actions UI
- See real-time logs
- View deployment history
- Check success/failure status

### AWS Lightsail Console
```
https://lightsail.aws.amazon.com/ls/webapp/ap-south-1/container-services/kram
```

### AWS CLI
```bash
aws lightsail get-container-services \
  --service-name kram \
  --region ap-south-1 \
  --query 'containerServices[0].currentDeployment.{Version:version,State:state}'
```

## 🚨 Troubleshooting

### Deployment Failed

1. **Check GitHub Actions logs**
   - Go to Actions tab
   - Click on failed run
   - Review error messages

2. **Common issues:**
   - Missing GitHub secrets
   - Docker build errors
   - Database migration failures
   - Health check timeouts

3. **View container logs:**
   ```bash
   aws lightsail get-container-log \
     --service-name kram \
     --container-name app \
     --region ap-south-1
   ```

### Frontend Not Updating

1. Check if frontend rebuild was skipped
2. Verify CloudFront invalidation ran
3. Hard refresh browser (Cmd + Shift + R)
4. Wait 3-5 minutes for cache to clear

### Health Check Failed

1. Check Lightsail logs for errors
2. Verify database connectivity
3. Check environment variables
4. Test Lightsail origin directly

## 💡 Best Practices

### When to Deploy

✅ **Deploy when:**
- Feature is tested locally
- Changes are committed and pushed
- Ready for users to see changes

❌ **Don't deploy when:**
- Code doesn't compile
- Tests are failing
- Database migrations not tested
- In middle of development

### Deployment Frequency

- **Testing phase:** Deploy as needed (manual trigger)
- **Active development:** 1-3 times per day
- **Production:** After thorough testing only

### Rollback Strategy

If deployment has issues:

1. **Quick rollback:**
   ```bash
   cd backend
   ./scripts/lightsail-deploy.sh
   ```

2. **Or:** Revert Git commit and redeploy via GitHub Actions

3. **Or:** Deploy previous working version from GitHub

## 📈 Monitoring

After deployment, monitor:

1. **Application health:**
   - https://api.kramedu.in/health
   - Check every 5 minutes for 30 minutes

2. **Error logs:**
   ```bash
   aws lightsail get-container-log \
     --service-name kram \
     --container-name app \
     --region ap-south-1 | grep -i error
   ```

3. **User reports:**
   - Watch for 404 errors
   - Check login functionality
   - Test critical features

## 🔐 Security Notes

- ⚠️ Never commit secrets to Git
- ⚠️ Rotate AWS keys periodically
- ⚠️ Use GitHub secret scanning
- ⚠️ Review who has access to secrets
- ⚠️ Use least privilege for AWS IAM

## 📞 Support

Need help? Check:
- [Backend Deployment Guide](../backend/LIGHTSAIL-DEPLOYMENT.md)
- [GitHub Actions Logs](../../actions)
- [AWS Lightsail Console](https://lightsail.aws.amazon.com)

---

**Last Updated:** February 8, 2026  
**Deployment Method:** GitHub Actions (Manual Trigger)  
**Target:** AWS Lightsail + CloudFront
