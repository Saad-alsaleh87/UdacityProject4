#!/bin/bash

# Script to get application URLs from Kubernetes

echo "======================================"
echo "Getting Application URLs"
echo "======================================"
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ kubectl is not configured or cannot connect to cluster"
    echo ""
    echo "Please configure kubectl first:"
    echo "  aws eks update-kubeconfig --name <CLUSTER_NAME> --region <REGION>"
    echo ""
    echo "Example:"
    echo "  aws eks update-kubeconfig --name udacity-cluster --region us-west-2"
    exit 1
fi

echo "✅ Connected to Kubernetes cluster"
echo ""

# Get namespace (try to auto-detect or use default)
NAMESPACE=${K8S_NAMESPACE:-default}

echo "Using namespace: $NAMESPACE"
echo ""

echo "======================================"
echo "All Services (for submission)"
echo "======================================"
kubectl get svc -A
echo ""

echo "======================================"
echo "Services in namespace: $NAMESPACE"
echo "======================================"
kubectl get svc -n $NAMESPACE -o wide
echo ""

echo "======================================"
echo "Pods Status"
echo "======================================"
kubectl get pods -n $NAMESPACE
echo ""

echo "======================================"
echo "Deployments"
echo "======================================"
kubectl get deployments -n $NAMESPACE
echo ""

# Try to get URLs
echo "======================================"
echo "Application URLs"
echo "======================================"

BACKEND_URL=$(kubectl get svc backend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
if [ -z "$BACKEND_URL" ]; then
    BACKEND_URL=$(kubectl get svc backend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
fi
if [ -z "$BACKEND_URL" ]; then
    BACKEND_URL=$(kubectl get svc backend-service -n $NAMESPACE -o jsonpath='{.spec.externalIPs[0]}' 2>/dev/null || echo "")
fi

FRONTEND_URL=$(kubectl get svc frontend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
if [ -z "$FRONTEND_URL" ]; then
    FRONTEND_URL=$(kubectl get svc frontend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
fi
if [ -z "$FRONTEND_URL" ]; then
    FRONTEND_URL=$(kubectl get svc frontend-service -n $NAMESPACE -o jsonpath='{.spec.externalIPs[0]}' 2>/dev/null || echo "")
fi

if [ -n "$BACKEND_URL" ]; then
    echo "Backend API: http://$BACKEND_URL:3000/movies"
    echo "Testing backend..."
    curl -s "http://$BACKEND_URL:3000/movies" | head -n 5
    echo ""
else
    echo "⚠️  Backend URL not found"
    echo "Try: kubectl get svc backend-service -n $NAMESPACE"
fi

echo ""

if [ -n "$FRONTEND_URL" ]; then
    echo "Frontend: http://$FRONTEND_URL"
    echo "Open this URL in your browser to test"
else
    echo "⚠️  Frontend URL not found"
    echo "Try: kubectl get svc frontend-service -n $NAMESPACE"
fi

echo ""
echo "======================================"
echo "Port Forward (for local testing)"
echo "======================================"
echo "To test locally with port forwarding:"
echo "  kubectl port-forward svc/backend-service 3000:3000 -n $NAMESPACE"
echo "  kubectl port-forward svc/frontend-service 8080:80 -n $NAMESPACE"
echo ""

