# GitHub Actions CI/CD Setup

This repository contains GitHub Actions workflows for continuous integration and deployment of a frontend and backend application to AWS EKS.

## Required GitHub Secrets

Create the following secrets in your GitHub repository settings:

### AWS Credentials
- `AWS_ACCESS_KEY_ID` - AWS access key ID
- `AWS_SECRET_ACCESS_KEY` - AWS secret access key
- `AWS_REGION` - AWS region (e.g., us-west-2)

### ECR Configuration
- `ECR_ACCOUNT_ID` - AWS account ID for ECR repository URL
- `ECR_REPOSITORY_FRONTEND` - ECR repository name for frontend
- `ECR_REPOSITORY_BACKEND` - ECR repository name for backend

### EKS Configuration
- `EKS_CLUSTER_NAME` - Name of your EKS cluster
- `K8S_NAMESPACE` - Kubernetes namespace for deployment

### Application Configuration
- `REACT_APP_MOVIE_API_URL` - Backend API URL for frontend build

## ECR Repository Setup

Create ECR repositories with names matching your secret values:

```bash
aws ecr create-repository --repository-name <ECR_REPOSITORY_FRONTEND>
aws ecr create-repository --repository-name <ECR_REPOSITORY_BACKEND>
```

## EKS Access Setup

### Option 1: IAM User (Recommended for GitHub Actions)
Create an IAM user with the following policies:
- `AmazonEKSClusterPolicy`
- `AmazonEKSWorkerNodePolicy`
- `AmazonEC2ContainerRegistryReadOnly`
- `AmazonEKS_CNI_Policy`

### Option 2: IAM Role
Create an IAM role with the above policies and configure GitHub Actions to assume the role.

## Workflow Files

- `.github/workflows/frontend-ci.yaml` - Frontend Continuous Integration
- `.github/workflows/backend-ci.yaml` - Backend Continuous Integration
- `.github/workflows/frontend-cd.yaml` - Frontend Continuous Deployment
- `.github/workflows/backend-cd.yaml` - Backend Continuous Deployment

## Verification Checklist

### Workflow Files
- [ ] All 4 workflow files exist in `.github/workflows/`
- [ ] Workflows trigger on pull requests to main branch
- [ ] Workflows can be triggered manually via `workflow_dispatch`
- [ ] Lint and test jobs run in parallel
- [ ] Build jobs depend on lint and test jobs (`needs: [lint, test]`)

### CI Workflows
- [ ] Frontend CI builds Docker image locally
- [ ] Backend CI builds Docker image locally
- [ ] All jobs fail when lint/test/build fail

### CD Workflows
- [ ] Docker images are pushed to ECR
- [ ] ECR login uses `aws-actions/amazon-ecr-login@v2`
- [ ] Frontend build includes `--build-arg REACT_APP_MOVIE_API_URL`
- [ ] Deployments use `kubectl` to apply to EKS
- [ ] AWS credentials configured via `aws-actions/configure-aws-credentials@v2`
- [ ] Kubeconfig updated with `aws eks update-kubeconfig`

### Application Verification
- [ ] Frontend application is accessible and can fetch movies
- [ ] Backend API returns movie list at `/movies` endpoint

## Testing Commands

### Verify Frontend Deployment
```bash
# Port forward to access frontend
kubectl port-forward deployment/frontend-deployment 3000:3000 -n <K8S_NAMESPACE>

# Visit http://localhost:3000 in browser
# Verify movies are displayed (fetched from backend)
```

### Verify Backend API
```bash
# Port forward to access backend
kubectl port-forward deployment/backend-deployment 3001:3000 -n <K8S_NAMESPACE>

# Test API endpoint
curl http://localhost:3001/movies
```

### Check Pod Status
```bash
kubectl get pods -n <K8S_NAMESPACE>
kubectl describe pod <pod-name> -n <K8S_NAMESPACE>
```

## Simulating Test Failures

To test that the CI pipeline fails when tests fail, you can:

### Method 1: Modify a Test File
```bash
# In a test file, change an assertion to fail
expect(result).toBe(true); // Change to expect(result).toBe(false);
```

### Method 2: Add a Failing Test
```bash
# Add this test to any test file
test('should fail', () => {
  expect(true).toBe(false);
});
```

### Method 3: Break Linting
```bash
# Add syntax error to any JavaScript file
const broken = { // Missing closing brace
```

After making any of these changes, create a pull request to trigger the CI workflow. The workflow should fail at the appropriate step (lint, test, or build).

## Node.js Version

All workflows use Node.js 18.x for consistency. The version is specified in the `setup-node` action and cached using `package-lock.json` for dependency caching.

## Caching Strategy

- Node modules are cached using `actions/cache@v3`
- Cache key includes OS, Node version, and `package-lock.json` hash
- Cache is restored before dependency installation for faster builds
