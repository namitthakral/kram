# Ed-Verse Backend Deployment Guide

## 🚀 Elastic Beanstalk Deployment

### Database Migration Strategy

Your application now has **automatic migrations** configured in two ways:

#### 1. `.ebextensions/01_migrations.config` (Primary)
Runs migrations during EB deployment lifecycle:
- Executes `npm run db:migrate:deploy` on the leader instance only
- Runs BEFORE the application starts
- Fails deployment if migrations fail (safe)

#### 2. `postinstall` script (Backup)
Runs after `npm install` completes:
- Only runs in production environment
- Executes `npm run db:migrate:deploy`

### Deployment Steps

#### Pre-Deployment Checklist

```bash
# 1. Ensure all changes are committed
git status

# 2. Build locally to verify
npm run build

# 3. Test migrations locally
npm run db:migrate:deploy

# 4. Verify Prisma client is generated
npx prisma generate

# 5. Check migration status
npx prisma migrate status
```

#### Deploy to Elastic Beanstalk

```bash
# Option A: Using EB CLI
eb deploy

# Option B: Using Git (if configured)
git push production master
```

### What Happens During Deployment

1. **Code Upload** - EB receives your application code
2. **npm install** - Dependencies are installed
3. **postinstall hook** - Migrations run (if NODE_ENV=production)
4. **Container Commands** - `.ebextensions` runs migrations (leader instance only)
5. **Application Start** - Procfile executes: `node dist/src/main`

### Migration Flow

```
EB Deploy
    ↓
npm install
    ↓
postinstall → npm run db:migrate:deploy (if production)
    ↓
Container Commands → npm run db:migrate:deploy (leader only)
    ↓
Application Start → node dist/src/main
```

### Monitoring Deployment

```bash
# Watch logs in real-time
eb logs --stream

# Check recent logs
eb logs

# SSH into instance to verify
eb ssh
cd /var/app/current
npx prisma migrate status
```

### Troubleshooting

#### If Migrations Fail

1. **Check EB logs:**
   ```bash
   eb logs
   ```

2. **SSH into instance:**
   ```bash
   eb ssh
   cd /var/app/current
   npx prisma migrate status
   ```

3. **Manual migration (if needed):**
   ```bash
   # While SSH'd into EB instance
   npm run db:migrate:deploy
   ```

4. **Rollback if necessary:**
   ```bash
   eb deploy --version <previous-version>
   ```

#### Common Issues

**Issue: "Can't reach database server"**
- Check DATABASE_URL environment variable
- Verify RDS security group allows EB instances
- Confirm VPC configuration

**Issue: "Migration already applied"**
- Safe to ignore, means migrations are up to date
- Verify with: `npx prisma migrate status`

**Issue: "Drift detected"**
- Database schema doesn't match migrations
- May need to: `npx prisma migrate resolve`
- Or baseline: `npx prisma migrate resolve --applied <migration-name>`

### Environment Variables

Ensure these are set in EB Configuration:

```bash
# Required
DATABASE_URL=postgresql://user:pass@host:5432/dbname
NODE_ENV=production
JWT_SECRET=your-production-secret
JWT_REFRESH_SECRET=different-production-secret

# Optional
PORT=3000
CORS_ORIGIN=https://yourdomain.com
RATE_LIMIT_TTL=60
RATE_LIMIT_MAX=100
```

### Manual Migration (Alternative)

If you prefer manual control:

1. **Remove** `.ebextensions/01_migrations.config`
2. **Remove** `postinstall` hook from `package.json`
3. **Run migrations manually** after each deployment:

```bash
# Connect to production DB locally
DATABASE_URL="your-production-url" npx prisma migrate deploy

# Or SSH into EB instance
eb ssh
cd /var/app/current
npm run db:migrate:deploy
```

### Database Backup Before Deployment

**ALWAYS backup before deploying schema changes:**

```bash
# AWS RDS Snapshot
aws rds create-db-snapshot \
  --db-instance-identifier your-db-instance \
  --db-snapshot-identifier edverse-backup-$(date +%Y%m%d-%H%M%S)

# Or manual dump
pg_dump -h your-host -U your-user -d edverse > backup-$(date +%Y%m%d).sql
```

### Rollback Strategy

If deployment fails:

```bash
# Rollback to previous version
eb deploy --version <previous-version-label>

# Or restore database from backup
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier your-db-instance \
  --db-snapshot-identifier your-snapshot-id
```

### Current Pending Migrations

You have **3 new migrations** to apply:

1. ✅ `phase1_remove_redundant_tables` - Removes analytics tables
2. ✅ `20260129143730_phase2_merge_communications` - Merges notices/announcements
3. ✅ `20260129192907_remove_redundant_analytics_tables` - Auto-generated cleanup

These will be applied automatically during your next deployment.

## 🔒 Security Considerations

- ✅ Migrations run on **leader instance only** (prevents race conditions)
- ✅ Deployment **fails if migrations fail** (data integrity)
- ✅ **No seed data** runs in production (prevents data overwrites)
- ✅ Migrations are **idempotent** (safe to run multiple times)

## 📊 Post-Deployment Verification

```bash
# 1. Check application health
curl https://your-app.elasticbeanstalk.com/health

# 2. Verify migrations
eb ssh
npx prisma migrate status

# 3. Test new Communications API
curl -H "Authorization: Bearer $TOKEN" \
  https://your-app.elasticbeanstalk.com/api/communications

# 4. Check logs for errors
eb logs --stream
```

## ✅ Safe Deployment Checklist

- [ ] Database backed up
- [ ] All changes committed to git
- [ ] Local build successful (`npm run build`)
- [ ] Migrations tested locally
- [ ] Environment variables verified in EB
- [ ] `.ebextensions/01_migrations.config` committed
- [ ] `postinstall` script added to package.json
- [ ] Deployment during low-traffic hours
- [ ] Team notified of deployment
- [ ] Rollback plan ready

---

**Last Updated:** January 29, 2026  
**Migration System:** Automated via .ebextensions + postinstall hook

