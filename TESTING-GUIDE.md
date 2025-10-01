# Testing Guide for CI/CD Workflows

This guide will help you test that all workflows work properly and get your application URLs for submission.

## Step 1: Test Locally (Optional but Recommended)

### Test Backend Locally
```bash
cd backend
npm install
npm run lint    # Should pass
npm run test    # Should pass
npm start       # Should start server on port 3000
```

In another terminal:
```bash
curl http://localhost:3000/movies
# Should return JSON array of movies
```

### Test Frontend Locally
```bash
cd frontend
npm install
npm run lint    # Should pass
npm run test -- --watchAll=false  # Should pass
npm run build   # Should build successfully
```

### Test Docker Builds Locally
```bash
# Test backend Docker build
docker build -t backend-test -f backend/Dockerfile backend/
docker run -p 3000:3000 backend-test
# Test: curl http://localhost:3000/movies

# Test frontend Docker build
docker build -t frontend-test -f frontend/Dockerfile frontend/
docker run -p 80:80 frontend-test
# Test: Open browser to http://localhost
```

## Step 2: Commit and Push Changes

```bash
# Stage all changes
git add .

# Commit
git commit -m "Add all 4 CI/CD workflows and fix backend test script"

# Push to main (this will trigger CD workflows)
git push origin main
```

## Step 3: Trigger and Verify CI Workflows

### Option A: Create a Test Pull Request (Triggers CI)
```bash
# Create a new branch
git checkout -b test-ci-workflows

# Make a small change
echo "# CI Test" >> README-github-actions.md

# Commit and push
git add README-github-actions.md
git commit -m "Test CI workflows"
git push origin test-ci-workflows
```

Then on GitHub:
1. Go to your repository
2. Click "Pull requests" → "New pull request"
3. Select `test-ci-workflows` branch
4. Create the pull request
5. **Both CI workflows should automatically run**
6. Merge the PR after workflows pass

### Option B: Manually Trigger Workflows
1. Go to GitHub → Your repository
2. Click "Actions" tab
3. Click on "Frontend Continuous Integration"
4. Click "Run workflow" → "Run workflow" button
5. Repeat for "Backend Continuous Integration"

## Step 4: Verify All 4 Workflows Show Success

Go to GitHub Actions page and verify:
- ✅ **Frontend Continuous Integration** - Green checkmark
- ✅ **Backend Continuous Integration** - Green checkmark  
- ✅ **Frontend Continuous Deployment** - Green checkmark
- ✅ **Backend Continuous Deployment** - Green checkmark

**Take screenshots of this page for your submission!**

## Step 5: Get Application URLs from Kubernetes

### Check if you have kubectl access
```bash
# Configure kubectl for your EKS cluster
aws eks update-kubeconfig --name <YOUR_EKS_CLUSTER_NAME> --region <YOUR_AWS_REGION>

# Example:
aws eks update-kubeconfig --name udacity-cluster --region us-west-2
```

### Get All Services and URLs
```bash
# Get all services (required for submission)
kubectl get svc -A

# This shows all services with their IPs/URLs
```

### Get Specific Service URLs
```bash
# Get frontend service URL
kubectl get svc frontend-service -n <YOUR_NAMESPACE>

# Get backend service URL  
kubectl get svc backend-service -n <YOUR_NAMESPACE>

# Example with default namespace:
kubectl get svc -n default
```

### If using LoadBalancer services:
```bash
# Get external URLs (LoadBalancer)
kubectl get svc -n <YOUR_NAMESPACE> -o wide

# The EXTERNAL-IP column will show your application URLs
```

### Test the URLs:
```bash
# Test backend API
curl http://<BACKEND_URL>:3000/movies

# Test frontend (open in browser)
# Navigate to: http://<FRONTEND_URL>
```

## Step 6: Verify Deployments are Running

```bash
# Check all pods are running
kubectl get pods -n <YOUR_NAMESPACE>

# Should show:
# NAME                                   READY   STATUS    RESTARTS   AGE
# backend-deployment-xxxxx               1/1     Running   0          5m
# frontend-deployment-xxxxx              1/1     Running   0          5m

# Check deployment status
kubectl get deployments -n <YOUR_NAMESPACE>

# Get detailed deployment info
kubectl describe deployment backend-deployment -n <YOUR_NAMESPACE>
kubectl describe deployment frontend-deployment -n <YOUR_NAMESPACE>
```

## Step 7: Test Applications End-to-End

### Test Backend API:
```bash
# Get movies endpoint
curl http://<BACKEND_URL>:3000/movies

# Expected response: JSON array of 5 movies
[
  {"id": 1, "title": "The Shawshank Redemption", "year": 1994},
  {"id": 2, "title": "The Godfather", "year": 1972},
  ...
]
```

### Test Frontend Application:
1. Open browser to `http://<FRONTEND_URL>`
2. Verify you see the movie list
3. Verify movies are loaded from the backend
4. Check browser console for any errors

## Step 8: Prepare Submission Materials

### Required Screenshots:
1. **GitHub Actions page** showing all 4 workflows with successful runs (green checkmarks)
2. **Frontend application** in browser showing the movie list
3. **Backend API response** (curl or browser showing JSON)
4. **kubectl get svc -A output** showing all services

### Required Information:
- Frontend URL: `http://<FRONTEND_URL>`
- Backend URL: `http://<BACKEND_URL>:3000/movies`
- GitHub repository URL
- Evidence that all 4 workflows ran successfully

## Troubleshooting

### If Workflows Fail:

#### Check GitHub Secrets are Set:
Go to GitHub → Settings → Secrets and variables → Actions

Required secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `ECR_ACCOUNT_ID`
- `ECR_REPOSITORY_FRONTEND`
- `ECR_REPOSITORY_BACKEND`
- `EKS_CLUSTER_NAME`
- `K8S_NAMESPACE`
- `REACT_APP_MOVIE_API_URL`

#### Check Workflow Logs:
1. Go to Actions tab
2. Click on the failed workflow run
3. Click on the failed job
4. Read the error messages

#### Common Issues:
- **Lint fails**: Fix linting errors in your code
- **Test fails**: Check test scripts in package.json
- **Build fails**: Check Dockerfile syntax
- **ECR push fails**: Verify AWS credentials and ECR repository exists
- **Deploy fails**: Verify EKS cluster name, namespace, and deployment names

### If Applications Don't Load:

```bash
# Check pod logs
kubectl logs -f deployment/backend-deployment -n <YOUR_NAMESPACE>
kubectl logs -f deployment/frontend-deployment -n <YOUR_NAMESPACE>

# Check pod status
kubectl describe pod <POD_NAME> -n <YOUR_NAMESPACE>

# Check service endpoints
kubectl get endpoints -n <YOUR_NAMESPACE>
```

### Test Image Manually in EKS:
```bash
# Get the latest image
aws ecr describe-images --repository-name <ECR_REPOSITORY_NAME> --region <AWS_REGION>

# Force new deployment
kubectl rollout restart deployment/backend-deployment -n <YOUR_NAMESPACE>
kubectl rollout restart deployment/frontend-deployment -n <YOUR_NAMESPACE>
```

## Quick Reference Commands

```bash
# View all workflows status
gh run list  # (requires GitHub CLI)

# View workflow logs
gh run view <RUN_ID> --log

# Get all Kubernetes resources
kubectl get all -n <YOUR_NAMESPACE>

# Port forward to test locally
kubectl port-forward svc/backend-service 3000:3000 -n <YOUR_NAMESPACE>
kubectl port-forward svc/frontend-service 8080:80 -n <YOUR_NAMESPACE>

# Check recent workflow runs
# Go to: https://github.com/<YOUR_USERNAME>/<YOUR_REPO>/actions
```

## Success Criteria

✅ All 4 workflow files exist in `.github/workflows/`:
- `frontend-ci.yaml`
- `backend-ci.yaml`
- `frontend-cd.yaml`
- `backend-cd.yaml`

✅ All 4 workflows have successful runs (green checkmarks) in GitHub Actions

✅ Frontend application is accessible and displays movies

✅ Backend API returns movie list at `/movies` endpoint

✅ You have screenshots proving all of the above

✅ You have the output of `kubectl get svc -A`

## Next Steps

1. Follow steps 1-8 above
2. Collect all screenshots and URLs
3. Resubmit your project with:
   - Screenshots of successful workflow runs
   - Frontend and Backend URLs
   - `kubectl get svc -A` output
   - Brief description of what each workflow does


