#!/bin/sh
# ============================================================================
# Ed-Verse Backend - Docker Entrypoint Script
# Handles database migrations with proper error handling
# ============================================================================

set -e  # Exit immediately if any command fails

echo "=================================================="
echo "🚀 Ed-Verse Backend Starting..."
echo "=================================================="
echo ""

# Function to handle errors
handle_error() {
    echo ""
    echo "❌ ERROR: $1"
    echo ""
    echo "🔍 Troubleshooting tips:"
    echo "  1. Check database connectivity"
    echo "  2. Verify DATABASE_URL is correct"
    echo "  3. Check migration files in prisma/migrations/"
    echo "  4. View logs: aws lightsail get-container-log --service-name kram"
    echo ""
    exit 1
}

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    handle_error "DATABASE_URL environment variable is not set"
fi

echo "✅ Environment variables loaded"
echo ""

# Run database migrations
echo "📊 Running database migrations..."
echo "=================================================="
if ! npx prisma migrate deploy; then
    handle_error "Database migrations failed! Container will not start."
fi

echo ""
echo "✅ Database migrations completed successfully!"
echo ""

# Check migration status
echo "🔍 Verifying migration status..."
if ! npx prisma migrate status; then
    echo "⚠️  Warning: Migration status check failed (non-critical)"
fi

echo ""
echo "=================================================="
echo "🚀 Starting NestJS application..."
echo "=================================================="
echo ""

# Start the application
exec node dist/src/main.js
