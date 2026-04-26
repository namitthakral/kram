#!/bin/bash

# Kram Monorepo Run Script
# This script helps you reset the database and start the development environment.

# Move to the root directory
cd "$(dirname "$0")/.."

echo "🚀 Starting Kram Development Environment..."

# Function to check and install dependencies
check_dependencies() {
    if [ ! -d "node_modules" ] || [ ! -d "backend/node_modules" ]; then
        echo "⚠️  Dependencies are missing!"
        read -p "❓ Do you want to run the setup script now? (y/N) " setup_answer
        if [[ "$setup_answer" =~ ^[Yy]$ ]]; then
            echo "📦 Running setup script..."
            ./scripts/setup.sh
        else
            echo "❌ Cannot proceed without dependencies. Please run ./scripts/setup.sh"
            exit 1
        fi
    fi
}

# Function to reset database
reset_database() {
    echo "♻️  Resetting database..."
    cd backend
    npm run db:reset
    npm run db:setup
    cd ..
    echo "✅ Database reset complete!"
}

# 1. Check dependencies first
check_dependencies

# 2. Ask for database reset
read -p "❓ Do you want to reset the database? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    reset_database
fi

# 3. Ask which frontend to run
echo "📱 Which frontend version do you want to run?"
echo "1) Frontend V2 (New - Default)"
echo "2) Frontend V1 (Legacy)"
echo "3) Backend Only"
read -p "Selection (1-3): " version

case $version in
    2)
        echo "📂 Starting Backend and Frontend V1..."
        npm run dev
        ;;
    3)
        echo "📂 Starting Backend Only..."
        npm run dev:backend
        ;;
    *)
        echo "📂 Starting Backend and Frontend V2..."
        npm run dev:v2
        ;;
esac
