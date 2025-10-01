# Test Workflows Locally Script (PowerShell)
# This script tests what the CI workflows will do (without deployment)

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing Backend CI Workflow Locally" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Set-Location backend

Write-Host "📦 Installing backend dependencies..." -ForegroundColor Yellow
npm ci

Write-Host "🔍 Running backend lint..." -ForegroundColor Yellow
npm run lint

Write-Host "✅ Running backend tests..." -ForegroundColor Yellow
npm run test

Write-Host "🐳 Building backend Docker image..." -ForegroundColor Yellow
Set-Location ..
docker build -t backend-test:latest -f backend/Dockerfile backend/

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing Frontend CI Workflow Locally" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Set-Location frontend

Write-Host "📦 Installing frontend dependencies..." -ForegroundColor Yellow
npm ci

Write-Host "🔍 Running frontend lint..." -ForegroundColor Yellow
npm run lint

Write-Host "✅ Running frontend tests..." -ForegroundColor Yellow
npm run test -- --watchAll=false

Write-Host "🐳 Building frontend Docker image..." -ForegroundColor Yellow
Set-Location ..
docker build -t frontend-test:latest -f frontend/Dockerfile frontend/

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "✅ ALL TESTS PASSED! ✅" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your workflows should pass on GitHub!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Commit and push your changes"
Write-Host "2. Check GitHub Actions for workflow runs"
Write-Host "3. Get your application URLs with: kubectl get svc -A"
Write-Host ""
Write-Host "To test the Docker images locally:" -ForegroundColor Yellow
Write-Host "  Backend:  docker run -p 3000:3000 backend-test:latest"
Write-Host "  Frontend: docker run -p 80:80 frontend-test:latest"
Write-Host ""

