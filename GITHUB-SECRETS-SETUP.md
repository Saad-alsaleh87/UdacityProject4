# GitHub Secrets Configuration Guide

This guide explains how to set up the required GitHub Secrets for the CI/CD workflows to deploy to AWS EKS.

## Required GitHub Secrets

You need to configure the following secrets in your GitHub repository:

### AWS Credentials

1. **AWS_ACCESS_KEY_ID**
   - Your AWS Access Key ID
   - Get this from AWS IAM or AWS Academy

2. **AWS_SECRET_ACCESS_KEY**
   - Your AWS Secret Access Key
   - Get this from AWS IAM or AWS Academy

3. **AWS_SESSION_TOKEN**
   - Your AWS Session Token (required for AWS Academy accounts)
   - Get this from AWS Academy
   - Note: This token expires periodically and will need to be updated

4. **AWS_REGION**
   - The AWS region where your resources are deployed
   - Example: `us-east-1`

### ECR and EKS Configuration

5. **ECR_REPOSITORY_FRONTEND**
   - The name of your ECR repository for the frontend
   - Example: `udacity-frontend`

6. **ECR_REPOSITORY_BACKEND**
   - The name of your ECR repository for the backend
   - Example: `udacity-backend`

7. **EKS_CLUSTER_NAME**
   - The name of your EKS cluster
   - Example: `udacity-cluster`

### Application Configuration

8. **REACT_APP_MOVIE_API_URL**
   - The URL of your backend API that the frontend will connect to
   - This should be the LoadBalancer URL of your backend service
   - Example: `http://backend-loadbalancer.us-east-1.elb.amazonaws.com:3000`

## How to Add Secrets to GitHub

1. Go to your GitHub repository
2. Click on **Settings**
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Enter the **Name** and **Value** for each secret
6. Click **Add secret**
7. Repeat for all 8 secrets listed above

## Getting AWS Credentials

### For AWS Academy Users:

1. Log in to AWS Academy
2. Go to your course
3. Click **AWS Details** or **AWS Console**
4. Click **Show** next to **AWS CLI credentials**
5. Copy the credentials:
   - `aws_access_key_id` → **AWS_ACCESS_KEY_ID**
   - `aws_secret_access_key` → **AWS_SECRET_ACCESS_KEY**
   - `aws_session_token` → **AWS_SESSION_TOKEN**

**Important:** AWS Academy session tokens expire after a few hours. You'll need to update the `AWS_SESSION_TOKEN` secret regularly (before each deployment).

### For Regular AWS Accounts:

1. Log in to AWS Console
2. Go to IAM
3. Create a user with appropriate permissions (ECR, EKS access)
4. Generate access keys
5. Copy the Access Key ID and Secret Access Key
6. You may not need `AWS_SESSION_TOKEN` for regular accounts (but the workflow expects it, so you can set it to an empty string or modify the workflow)

## Verifying Your Setup

After adding all secrets:

1. The secrets should be listed in **Settings** → **Secrets and variables** → **Actions**
2. You won't be able to view the values (for security), but you'll see the names
3. The workflows will automatically use these secrets when they run

## ECR Repository Names

Based on your k8s deployment files, your ECR repositories appear to be:
- Frontend: `udacity-frontend`
- Backend: `udacity-backend`

Make sure these repositories exist in ECR before running the CD workflows.

## EKS Cluster Name

Check your EKS cluster name by running:
```bash
aws eks list-clusters --region us-east-1
```

## Troubleshooting

- **Authentication errors**: Check if your AWS credentials are correct and not expired
- **ECR push fails**: Verify the ECR repository exists and your IAM user has ECR permissions
- **EKS deployment fails**: Ensure your EKS cluster exists and your IAM user has EKS permissions
- **Session token expired**: Update the `AWS_SESSION_TOKEN` secret with fresh credentials from AWS Academy

