#!/bin/sh
# ============================================================================
# Kram Backend - Docker Entrypoint Script
# ============================================================================
# NOTE: This script does NOT run migrations!
# Migrations should be run BEFORE deployment using deploy-to-production.sh
# ============================================================================

set -e  # Exit immediately if any command fails

echo "=================================================="
echo "🚀 Kram Backend Starting..."
echo "=================================================="
echo ""

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo "❌ ERROR: DATABASE_URL environment variable is not set"
    echo ""
    echo "🔍 Troubleshooting tips:"
    echo "  1. Verify .env.production has DATABASE_URL"
    echo "  2. Check deployment configuration"
    echo "  3. View logs: aws lightsail get-container-log --service-name kram"
    echo ""
    exit 1
fi

echo "✅ Environment variables loaded"
echo "📊 Database: ${DATABASE_URL:0:50}..."
echo ""

echo "=================================================="
echo "🚀 Starting NestJS application..."
echo "=================================================="
echo ""
echo "ℹ️  NOTE: Migrations should be run via deploy-to-production.sh"
echo "   This container only runs the application."
echo ""

# Start the application
exec node dist/main.js
