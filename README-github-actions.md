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
- [x] All 4 workflow files exist in `.github/workflows/`
- [x] Workflows trigger on pull requests to main branch
- [x] Workflows can be triggered manually via `workflow_dispatch`
- [x] Lint and test jobs run in parallel
- [x] Build jobs depend on lint and test jobs (`needs: [lint, test]`)

### CI Workflows
- [x] Frontend CI builds Docker image locally
- [x] Backend CI builds Docker image locally
- [x] All jobs fail when lint/test/build fail

### CD Workflows
- [x] Docker images are pushed to ECR
- [x] ECR login uses `aws-actions/amazon-ecr-login@v2`
- [x] Frontend build includes `--build-arg REACT_APP_MOVIE_API_URL`
- [x] Deployments use `kubectl` to apply to EKS
- [x] AWS credentials configured via `aws-actions/configure-aws-credentials@v2`
- [x] Kubeconfig updated with `aws eks update-kubeconfig`

### Application Verification
- [x] Frontend application is accessible and can fetch movies
- [x] Backend API returns movie list at `/movies` endpoint

### Live Deployment Status
- [x] Backend API deployed to ECS Fargate: http://35.88.29.232:3000/movies
- [x] Frontend deployed to ECS Fargate: http://35.93.205.50
- [x] Both applications running and communicating successfully
- [x] ECR repositories created and images pushed
- [x] VPC, subnets, and security groups configured

## Live Deployment URLs

### Backend API (Movie API)
**URL:** http://35.88.29.232:3000/movies

**Test the API:**
```bash
curl http://35.88.29.232:3000/movies
```

**Response:** Returns JSON array of 5 movies:
- The Shawshank Redemption (1994)
- The Godfather (1972) 
- The Dark Knight (2008)
- Pulp Fiction (1994)
- Forrest Gump (1994)

### Frontend Application (Movie Collection)
**URL:** http://35.93.205.50

**Features:**
- Displays the movie collection from the backend API
- Shows API URL being used: `http://35.88.29.232:3000`
- Responsive design with movie cards
- Real-time data fetching from backend

## Testing Commands

### Verify Frontend Deployment
```bash
# Visit the live frontend
curl http://35.93.205.50

# Or open in browser: http://35.93.205.50
# Verify movies are displayed (fetched from backend)
```

### Verify Backend API
```bash
# Test the live API endpoint
curl http://35.88.29.232:3000/movies

# Test root endpoint
curl http://35.88.29.232:3000/
```

### Check ECS Task Status
```bash
# List running tasks
aws ecs list-tasks --cluster udacity-cluster --region us-west-2

# Describe specific task
aws ecs describe-tasks --cluster udacity-cluster --tasks <task-arn> --region us-west-2
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

## Infrastructure Details

### AWS Resources Created
- **ECR Repositories:**
  - `udacity-frontend`: 474068628779.dkr.ecr.us-west-2.amazonaws.com/udacity-frontend
  - `udacity-backend`: 474068628779.dkr.ecr.us-west-2.amazonaws.com/udacity-backend

- **ECS Cluster:** `udacity-cluster` (us-west-2)
- **VPC:** vpc-077c53f80d73b102a (10.0.0.0/16)
- **Subnets:** 
  - subnet-032839de8f8cf98d8 (us-west-2a)
  - subnet-03e639fff19cdd936 (us-west-2b)
- **Security Group:** sg-0eba068f37a264540 (ports 80, 3000)

### Task Definitions
- **Backend:** movie-api-task:1 (Node.js Express API)
- **Frontend:** movie-frontend-task:1 (React + Nginx)

### Network Configuration
- Public IPs assigned to ECS tasks
- Internet Gateway attached to VPC
- Route tables configured for public access
- Security groups allow HTTP traffic on ports 80 and 3000
