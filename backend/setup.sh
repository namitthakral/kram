#!/bin/bash

# Ed-verse Backend Setup Script
echo "🚀 Setting up Ed-verse Backend..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js v18+ first."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version 18+ is required. Current version: $(node -v)"
    exit 1
fi

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "⚠️  PostgreSQL is not installed. Please install PostgreSQL first."
    echo "   Visit: https://www.postgresql.org/download/"
fi

echo "✅ Node.js $(node -v) detected"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "✅ Created .env file - please configure your database URL and JWT secret"
else
    echo "✅ .env file already exists"
fi

# Generate Prisma client
echo "🔧 Generating Prisma client..."
npm run db:generate

if [ $? -ne 0 ]; then
    echo "❌ Failed to generate Prisma client"
    exit 1
fi

echo ""
echo "🎉 Backend setup complete!"
echo ""
echo "Next steps:"
echo "1. Configure your database URL in .env file"
echo "2. Set a strong JWT_SECRET in .env file"
echo "3. Run 'npm run db:push' to create database tables"
echo "4. Run 'npm run db:seed' to populate with sample data"
echo "5. Run 'npm run dev' to start the development server"
echo ""
echo "Sample accounts will be created:"
echo "- Super Admin: admin@edverse.edu / admin123!"
echo "- Teacher: john.doe@edverse.edu / teacher123!"
echo "- Student: jane.smith@edverse.edu / student123!"
echo "- Parent: robert.smith@email.com / parent123!"
echo ""
echo "API will be available at: http://localhost:3000"
echo "Health check: http://localhost:3000/health"
