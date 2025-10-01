# GitHub Secrets Setup Guide

## Step 1: Configure AWS Credentials

First, configure your AWS credentials locally:

```powershell
aws configure
```

Enter:
- **AWS Access Key ID**: Your access key
- **AWS Secret Access Key**: Your secret key  
- **Default region**: `us-east-1` (or your preferred region)
- **Default output format**: `json`

## Step 2: Get Your AWS Account ID

After configuring credentials, run:
```powershell
aws sts get-caller-identity --query Account --output text
```

This will give you your AWS Account ID (12-digit number).

## Step 3: Check Your AWS Resources

### Check ECR Repositories:
```powershell
aws ecr describe-repositories --region us-east-1
```

### Check EKS Clusters:
```powershell
aws eks list-clusters --region us-east-1
```

## Step 4: Add GitHub Secrets

Go to: **https://github.com/Saad-alsaleh87/UdacityProject4/settings/secrets/actions**

Click **"New repository secret"** and add each of these:

### Required Secrets:

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | AWS IAM → Users → Your User → Security credentials |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | Same as above |
| `AWS_REGION` | `us-east-1` | Your preferred AWS region |
| `ECR_ACCOUNT_ID` | 12-digit number | From `aws sts get-caller-identity` |
| `ECR_REPOSITORY_FRONTEND` | `udacity-frontend` | ECR repository name for frontend |
| `ECR_REPOSITORY_BACKEND` | `udacity-backend` | ECR repository name for backend |
| `EKS_CLUSTER_NAME` | `udacity-cluster` | Your EKS cluster name |
| `K8S_NAMESPACE` | `default` | Kubernetes namespace |
| `REACT_APP_MOVIE_API_URL` | `http://your-backend-url:3000` | Backend API URL |

## Step 5: Create Missing Resources (if needed)

### Create ECR Repositories:
```powershell
aws ecr create-repository --repository-name udacity-frontend --region us-east-1
aws ecr create-repository --repository-name udacity-backend --region us-east-1
```

### Create EKS Cluster (if needed):
```powershell
eksctl create cluster --name udacity-cluster --region us-east-1 --nodegroup-name workers --node-type t3.medium --nodes 2
```

## Step 6: Test the Setup

After adding all secrets, trigger the workflow again:
1. Go to GitHub Actions
2. Click on a failed workflow
3. Click "Re-run jobs"

## Troubleshooting

### If you get "ExpiredToken" error:
- Your AWS credentials are expired
- Reconfigure with `aws configure`
- Or get new temporary credentials

### If you get "AccessDenied" error:
- Your AWS user doesn't have required permissions
- Add these policies to your IAM user:
  - `AmazonEC2ContainerRegistryFullAccess`
  - `AmazonEKSClusterPolicy`
  - `AmazonEKSWorkerNodePolicy`
  - `AmazonEKS_CNI_Policy`

### If ECR repositories don't exist:
- Create them with the commands above
- Or use existing repository names in the secrets

### If EKS cluster doesn't exist:
- Create one with eksctl or AWS Console
- Or use an existing cluster name

## Quick Commands Summary

```powershell
# Configure AWS
aws configure

# Get account ID
aws sts get-caller-identity --query Account --output text

# List ECR repos
aws ecr describe-repositories --region us-east-1

# List EKS clusters  
aws eks list-clusters --region us-east-1

# Create ECR repos (if needed)
aws ecr create-repository --repository-name udacity-frontend --region us-east-1
aws ecr create-repository --repository-name udacity-backend --region us-east-1
```

