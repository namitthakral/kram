#!/bin/bash

# Kram Monorepo Setup Script
echo "🚀 Setting up Kram monorepo..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js v18+ first."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "⚠️  Flutter is not installed. Please install Flutter to run the frontend."
    echo "   Visit: https://flutter.dev/docs/get-started/install"
fi

# Install root dependencies
echo "📦 Installing root dependencies..."
npm install

# Install backend dependencies
echo "📦 Installing backend dependencies..."
cd backend && npm install && cd ..

# Get Flutter dependencies (if Flutter is available)
if command -v flutter &> /dev/null; then
    echo "📦 Installing Flutter dependencies..."
    cd frontend && flutter pub get && cd ..
    echo "📦 Installing Flutter dependencies for v2..."
    cd frontend-v2 && flutter pub get && cd ..
else
    echo "⏭️  Skipping Flutter dependencies (Flutter not installed)"
fi

# Copy environment file
if [ ! -f "backend/.env" ]; then
    echo "📝 Creating backend environment file..."
    cp backend/.env.example backend/.env
    echo "✅ Created backend/.env - please configure your environment variables"
else
    echo "✅ Backend .env file already exists"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Configure your environment variables in backend/.env"
echo "2. Run 'npm run dev' to start development servers"
echo "3. Backend will be available at http://localhost:3000"
echo "4. Frontend will start on your default device/browser"
echo ""
