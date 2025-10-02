# Evidence of Working CI/CD Pipeline

## 🔗 Public Repository & Job Runs

**GitHub Repository (Public):** https://github.com/Saad-alsaleh87/UdacityProject4

**GitHub Actions (Analyze all job runs):** https://github.com/Saad-alsaleh87/UdacityProject4/actions

> The repository is **public** so you can directly analyze all workflow runs, job executions, and view the complete CI/CD pipeline implementation.

---

## 🎯 Live Application URLs

### Frontend Application
**URL:** http://ae69d9026ae87434a942068173f7a006-997290690.us-east-1.elb.amazonaws.com

**What you'll see:**
- Movie Collection web application
- Displays 5 movies fetched from the backend API
- Shows the backend API URL being used
- Modern, responsive UI

### Backend API
**URL:** http://aa8634e3d563c4052a71f0b2626c3442-1813112696.us-east-1.elb.amazonaws.com:3000/movies

**Test it:**
```bash
curl http://aa8634e3d563c4052a71f0b2626c3442-1813112696.us-east-1.elb.amazonaws.com:3000/movies
```

**Returns:** JSON array with 5 movies:
```json
[
  {"id":1,"title":"The Shawshank Redemption","year":"1994"},
  {"id":2,"title":"The Godfather","year":"1972"},
  {"id":3,"title":"The Dark Knight","year":"2008"},
  {"id":4,"title":"Pulp Fiction","year":"1994"},
  {"id":5,"title":"Forrest Gump","year":"1994"}
]
```

---

## 📋 CI/CD Workflows

All 4 workflows are in `.github/workflows/`:

### CI Workflows (Pull Requests)
- ✅ **frontend-ci.yaml** - Lint, test, build frontend
- ✅ **backend-ci.yaml** - Lint, test, build backend

### CD Workflows (Push to Main)
- ✅ **frontend-cd.yaml** - Build, push to ECR, deploy to EKS
- ✅ **backend-cd.yaml** - Build, push to ECR, deploy to EKS

**View all runs:** https://github.com/Saad-alsaleh87/UdacityProject4/actions

---

## 🏗️ Infrastructure

### AWS Resources
- **Region:** us-east-1
- **EKS Cluster:** udacity-cluster
- **ECR Account:** 474068628779
- **ECR Repositories:**
  - `udacity-frontend`
  - `udacity-backend`

### Deployments
- **Frontend:** 2 replicas (React + Nginx)
- **Backend:** 2 replicas (Node.js Express)
- **Service Type:** LoadBalancer (for public access)

---

## ✅ Verification

To verify the deployment is working:

```bash
# Configure kubectl
aws eks update-kubeconfig --name udacity-cluster --region us-east-1

# Check services
kubectl get svc -n default

# Expected output:
# backend-service    LoadBalancer   aa8634e3d563c4052a71f0b2626c3442-1813112696.us-east-1.elb.amazonaws.com
# frontend-service   LoadBalancer   ae69d9026ae87434a942068173f7a006-997290690.us-east-1.elb.amazonaws.com
```

---

## 📝 Submission Summary

**Repository URL:** https://github.com/Saad-alsaleh87/UdacityProject4

**GitHub Actions URL:** https://github.com/Saad-alsaleh87/UdacityProject4/actions

**Frontend URL:** http://ae69d9026ae87434a942068173f7a006-997290690.us-east-1.elb.amazonaws.com

**Backend URL:** http://aa8634e3d563c4052a71f0b2626c3442-1813112696.us-east-1.elb.amazonaws.com:3000/movies

---

**All requirements met:**
- ✅ 4 workflows created and working
- ✅ CI/CD pipelines executing successfully (visible in GitHub Actions)
- ✅ Docker images pushed to ECR
- ✅ Applications deployed to EKS
- ✅ Live URLs accessible and working
- ✅ Public repository available for review
