# Database Migrations Guide

This project uses **Prisma Migrate** for database schema management.

## 📚 Why Migrations?

- ✅ Version control for database changes
- ✅ Rollback capability
- ✅ Team collaboration
- ✅ Production safety
- ✅ Audit trail of all changes

---

## 🚀 Common Workflows

### **1. Making Schema Changes (Development)**

When you want to change the database schema:

```bash
# 1. Edit prisma/schema.prisma
# Add/modify models, fields, etc.

# 2. Create and apply migration
npm run db:migrate -- --name descriptive_change_name

# Example:
npm run db:migrate -- --name add_user_avatar_field

# This will:
# - Create a new migration file
# - Apply it to your local database
# - Regenerate Prisma Client
```

### **2. Deploying to Production**

When you deploy to Elastic Beanstalk:

```bash
# Commit your migration files
git add prisma/migrations/
git commit -m "Add user avatar field"

# Deploy
eb deploy

# EB will automatically run: npx prisma migrate deploy
```

The `.ebextensions/02_prisma_migrate.config` handles this automatically.

### **3. Checking Migration Status**

```bash
# See which migrations are applied
npx prisma migrate status

# Production database
DATABASE_URL="postgresql://..." npx prisma migrate status
```

### **4. Rolling Back Migrations**

If you need to undo a migration:

```bash
# Undo the last migration (local only)
npm run db:reset

# For production, you need to:
# 1. Create a new migration that reverses the changes
# 2. Deploy that migration
```

---

## 📝 Migration Naming Conventions

Use descriptive names that explain **what** changed:

✅ **Good Examples:**
- `add_user_avatar_field`
- `create_notifications_table`
- `add_index_to_email`
- `rename_status_to_active_status`

❌ **Bad Examples:**
- `update_schema`
- `changes`
- `fix`

---

## 🛠️ Useful Commands

```bash
# Generate Prisma Client (after schema changes)
npm run db:generate

# Open Prisma Studio (visual DB browser)
npm run db:studio

# Create migration without applying (review SQL first)
npx prisma migrate dev --create-only

# Then apply it
npx prisma migrate dev

# Deploy migrations to production
npm run db:migrate:deploy

# Reset database (WARNING: Deletes all data)
npm run db:reset

# Seed database with test data
npm run db:seed

# Full setup (generate + migrate + seed)
npm run db:setup
```

---

## 🔄 Workflow Example

### **Adding a New Feature:**

```bash
# 1. Create a branch
git checkout -b feature/user-notifications

# 2. Edit schema
# Add Notification model to prisma/schema.prisma

# 3. Create migration
npm run db:migrate -- --name add_notifications_table

# 4. Develop your feature
# ... write code ...

# 5. Commit everything
git add .
git commit -m "Add notifications feature"

# 6. Deploy to production
git push origin feature/user-notifications
# After PR approval:
git checkout main
git merge feature/user-notifications
eb deploy
```

---

## ⚠️ Important Notes

### **DO:**
- ✅ Always commit migration files to Git
- ✅ Test migrations on a staging database first
- ✅ Use descriptive migration names
- ✅ Review the generated SQL before applying
- ✅ Create one migration per logical change

### **DON'T:**
- ❌ Edit migration files after they're applied
- ❌ Delete migration files
- ❌ Use `db push` in production
- ❌ Manually modify the `_prisma_migrations` table
- ❌ Skip migrations when deploying

---

## 🐛 Troubleshooting

### **Migration Failed to Apply**

```bash
# Check migration status
npx prisma migrate status

# If stuck, resolve manually
npx prisma migrate resolve --applied <migration_name>
# or
npx prisma migrate resolve --rolled-back <migration_name>
```

### **Schema Drift Detected**

This means your database doesn't match your migrations:

```bash
# Option 1: Reset database (development only)
npm run db:reset

# Option 2: Create a baseline migration (production)
npx prisma migrate diff \
  --from-empty \
  --to-schema-datamodel prisma/schema.prisma \
  --script > temp_migration.sql
# Review and apply manually
```

### **Production Database Out of Sync**

```bash
# Check what's missing
DATABASE_URL="postgresql://..." npx prisma migrate status

# Deploy missing migrations
DATABASE_URL="postgresql://..." npx prisma migrate deploy
```

---

## 📦 Files to Commit

Always commit these files to Git:

```
prisma/
  ├── schema.prisma           ✅ Commit
  ├── migrations/
  │   ├── migration_lock.toml ✅ Commit
  │   ├── 20260127_init/
  │   │   └── migration.sql   ✅ Commit
  │   └── 20260128_add_field/
  │       └── migration.sql   ✅ Commit
  └── seed.ts                 ✅ Commit
```

---

## 🔗 Resources

- [Prisma Migrate Docs](https://www.prisma.io/docs/concepts/components/prisma-migrate)
- [Migration Troubleshooting](https://www.prisma.io/docs/guides/database/developing-with-prisma-migrate/troubleshooting-development)
- [Production Best Practices](https://www.prisma.io/docs/guides/database/production-troubleshooting)

---

## 📊 Current Setup

- **Environment:** AWS RDS PostgreSQL
- **Host:** `kram-db.chu82aoyy194.ap-south-1.rds.amazonaws.com`
- **Database:** `postgres`
- **Deployment:** Elastic Beanstalk with auto-migration
- **Baseline Migration:** `20260127164543_init`

---

**Questions?** Check the Prisma docs or ask your team!

