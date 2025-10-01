# Script to get application URLs from Kubernetes (PowerShell)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Getting Application URLs" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if kubectl is configured
try {
    kubectl cluster-info 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "kubectl not configured"
    }
} catch {
    Write-Host "❌ kubectl is not configured or cannot connect to cluster" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please configure kubectl first:" -ForegroundColor Yellow
    Write-Host "  aws eks update-kubeconfig --name <CLUSTER_NAME> --region <REGION>"
    Write-Host ""
    Write-Host "Example:" -ForegroundColor Yellow
    Write-Host "  aws eks update-kubeconfig --name udacity-cluster --region us-west-2"
    exit 1
}

Write-Host "✅ Connected to Kubernetes cluster" -ForegroundColor Green
Write-Host ""

# Get namespace (try to auto-detect or use default)
$NAMESPACE = if ($env:K8S_NAMESPACE) { $env:K8S_NAMESPACE } else { "default" }

Write-Host "Using namespace: $NAMESPACE" -ForegroundColor Yellow
Write-Host ""

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "All Services (for submission)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
kubectl get svc -A
Write-Host ""

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Services in namespace: $NAMESPACE" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
kubectl get svc -n $NAMESPACE -o wide
Write-Host ""

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Pods Status" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
kubectl get pods -n $NAMESPACE
Write-Host ""

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Deployments" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
kubectl get deployments -n $NAMESPACE
Write-Host ""

# Try to get URLs
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Application URLs" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Get Backend URL
try {
    $BACKEND_URL = kubectl get svc backend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>$null
    if ([string]::IsNullOrEmpty($BACKEND_URL)) {
        $BACKEND_URL = kubectl get svc backend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null
    }
    if ([string]::IsNullOrEmpty($BACKEND_URL)) {
        $BACKEND_URL = kubectl get svc backend-service -n $NAMESPACE -o jsonpath='{.spec.externalIPs[0]}' 2>$null
    }
} catch {
    $BACKEND_URL = ""
}

# Get Frontend URL
try {
    $FRONTEND_URL = kubectl get svc frontend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>$null
    if ([string]::IsNullOrEmpty($FRONTEND_URL)) {
        $FRONTEND_URL = kubectl get svc frontend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null
    }
    if ([string]::IsNullOrEmpty($FRONTEND_URL)) {
        $FRONTEND_URL = kubectl get svc frontend-service -n $NAMESPACE -o jsonpath='{.spec.externalIPs[0]}' 2>$null
    }
} catch {
    $FRONTEND_URL = ""
}

if (![string]::IsNullOrEmpty($BACKEND_URL)) {
    Write-Host "Backend API: http://$BACKEND_URL:3000/movies" -ForegroundColor Green
    Write-Host "Testing backend..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://$BACKEND_URL:3000/movies" -UseBasicParsing
        Write-Host $response.Content.Substring(0, [Math]::Min(500, $response.Content.Length))
    } catch {
        Write-Host "Could not test backend (might not be ready yet)" -ForegroundColor Yellow
    }
    Write-Host ""
} else {
    Write-Host "⚠️  Backend URL not found" -ForegroundColor Yellow
    Write-Host "Try: kubectl get svc backend-service -n $NAMESPACE"
}

Write-Host ""

if (![string]::IsNullOrEmpty($FRONTEND_URL)) {
    Write-Host "Frontend: http://$FRONTEND_URL" -ForegroundColor Green
    Write-Host "Open this URL in your browser to test" -ForegroundColor Yellow
} else {
    Write-Host "⚠️  Frontend URL not found" -ForegroundColor Yellow
    Write-Host "Try: kubectl get svc frontend-service -n $NAMESPACE"
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Port Forward (for local testing)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "To test locally with port forwarding:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward svc/backend-service 3000:3000 -n $NAMESPACE"
Write-Host "  kubectl port-forward svc/frontend-service 8080:80 -n $NAMESPACE"
Write-Host ""


