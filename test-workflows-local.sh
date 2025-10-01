#!/bin/bash

# Test Workflows Locally Script
# This script tests what the CI workflows will do (without deployment)

set -e  # Exit on any error

echo "======================================"
echo "Testing Backend CI Workflow Locally"
echo "======================================"

cd backend

echo "📦 Installing backend dependencies..."
npm ci

echo "🔍 Running backend lint..."
npm run lint

echo "✅ Running backend tests..."
npm run test

echo "🐳 Building backend Docker image..."
cd ..
docker build -t backend-test:latest -f backend/Dockerfile backend/

echo ""
echo "======================================"
echo "Testing Frontend CI Workflow Locally"
echo "======================================"

cd frontend

echo "📦 Installing frontend dependencies..."
npm ci

echo "🔍 Running frontend lint..."
npm run lint

echo "✅ Running frontend tests..."
npm run test -- --watchAll=false

echo "🐳 Building frontend Docker image..."
cd ..
docker build -t frontend-test:latest -f frontend/Dockerfile frontend/

echo ""
echo "======================================"
echo "✅ ALL TESTS PASSED! ✅"
echo "======================================"
echo ""
echo "Your workflows should pass on GitHub!"
echo ""
echo "Next steps:"
echo "1. Commit and push your changes"
echo "2. Check GitHub Actions for workflow runs"
echo "3. Get your application URLs with: kubectl get svc -A"
echo ""
echo "To test the Docker images locally:"
echo "  Backend:  docker run -p 3000:3000 backend-test:latest"
echo "  Frontend: docker run -p 80:80 frontend-test:latest"
echo ""

