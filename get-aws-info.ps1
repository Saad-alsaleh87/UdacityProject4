# Script to Get AWS Information for GitHub Secrets

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "AWS Information for GitHub Secrets" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if AWS CLI is installed
try {
    $awsVersion = aws --version 2>&1
    Write-Host "✅ AWS CLI installed: $awsVersion" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ AWS CLI not installed" -ForegroundColor Red
    Write-Host "Install from: https://aws.amazon.com/cli/" -ForegroundColor Yellow
    exit 1
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "AWS Account Information" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Get AWS Account ID
try {
    $accountId = aws sts get-caller-identity --query Account --output text 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "AWS Account ID (ECR_ACCOUNT_ID):" -ForegroundColor Yellow
        Write-Host "  $accountId" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "❌ Could not get Account ID. Please configure AWS credentials." -ForegroundColor Red
        Write-Host ""
    }
} catch {
    Write-Host "❌ Error getting account ID" -ForegroundColor Red
    Write-Host ""
}

# Get AWS Region
try {
    $region = aws configure get region 2>&1
    if ([string]::IsNullOrEmpty($region)) {
        $region = "Not configured"
        Write-Host "AWS Region (AWS_REGION):" -ForegroundColor Yellow
        Write-Host "  $region - Please set it manually" -ForegroundColor Red
        Write-Host "  Example: us-west-2, us-east-1, eu-west-1" -ForegroundColor Cyan
    } else {
        Write-Host "AWS Region (AWS_REGION):" -ForegroundColor Yellow
        Write-Host "  $region" -ForegroundColor Green
    }
    Write-Host ""
} catch {
    Write-Host "❌ Error getting region" -ForegroundColor Red
    Write-Host ""
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "ECR Repositories" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

if (![string]::IsNullOrEmpty($region) -and $region -ne "Not configured") {
    try {
        $repos = aws ecr describe-repositories --region $region --output json 2>&1 | ConvertFrom-Json
        if ($repos.repositories.Count -gt 0) {
            Write-Host "Found ECR Repositories:" -ForegroundColor Green
            foreach ($repo in $repos.repositories) {
                Write-Host "  - $($repo.repositoryName)" -ForegroundColor Cyan
                if ($repo.repositoryName -like "*frontend*") {
                    Write-Host "    → Use for ECR_REPOSITORY_FRONTEND" -ForegroundColor Yellow
                }
                if ($repo.repositoryName -like "*backend*") {
                    Write-Host "    → Use for ECR_REPOSITORY_BACKEND" -ForegroundColor Yellow
                }
            }
        } else {
            Write-Host "⚠️  No ECR repositories found" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Create them with:" -ForegroundColor Cyan
            Write-Host "  aws ecr create-repository --repository-name udacity-frontend --region $region"
            Write-Host "  aws ecr create-repository --repository-name udacity-backend --region $region"
        }
    } catch {
        Write-Host "⚠️  Could not list ECR repositories" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Cannot check ECR repositories without region configured" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "EKS Clusters" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

if (![string]::IsNullOrEmpty($region) -and $region -ne "Not configured") {
    try {
        $clusters = aws eks list-clusters --region $region --output json 2>&1 | ConvertFrom-Json
        if ($clusters.clusters.Count -gt 0) {
            Write-Host "Found EKS Clusters (EKS_CLUSTER_NAME):" -ForegroundColor Green
            foreach ($cluster in $clusters.clusters) {
                Write-Host "  - $cluster" -ForegroundColor Cyan
            }
        } else {
            Write-Host "⚠️  No EKS clusters found in region $region" -ForegroundColor Yellow
            Write-Host "You need to create an EKS cluster first" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠️  Could not list EKS clusters" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Cannot check EKS clusters without region configured" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Summary - Add These to GitHub Secrets" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Go to: https://github.com/Saad-alsaleh87/UdacityProject4/settings/secrets/actions" -ForegroundColor Cyan
Write-Host ""
Write-Host "Add these secrets:" -ForegroundColor Yellow
Write-Host "  1. AWS_ACCESS_KEY_ID - Your AWS access key" -ForegroundColor White
Write-Host "  2. AWS_SECRET_ACCESS_KEY - Your AWS secret key" -ForegroundColor White
Write-Host "  3. AWS_REGION - $region" -ForegroundColor White
if (![string]::IsNullOrEmpty($accountId)) {
    Write-Host "  4. ECR_ACCOUNT_ID - $accountId" -ForegroundColor White
} else {
    Write-Host "  4. ECR_ACCOUNT_ID - Your AWS account ID" -ForegroundColor White
}
Write-Host "  5. ECR_REPOSITORY_FRONTEND - (ECR frontend repo name)" -ForegroundColor White
Write-Host "  6. ECR_REPOSITORY_BACKEND - (ECR backend repo name)" -ForegroundColor White
Write-Host "  7. EKS_CLUSTER_NAME - (Your EKS cluster name)" -ForegroundColor White
Write-Host "  8. K8S_NAMESPACE - default (or your namespace)" -ForegroundColor White
Write-Host "  9. REACT_APP_MOVIE_API_URL - http://backend-url:3000" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  Note: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY" -ForegroundColor Yellow
Write-Host "    can be found in AWS IAM → Users → Security credentials" -ForegroundColor Yellow
Write-Host ""


