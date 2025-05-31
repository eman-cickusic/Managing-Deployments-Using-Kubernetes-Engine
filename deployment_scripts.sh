#!/bin/bash

# Kubernetes Deployment Script
# This script automates the deployment of the microservices application

set -e

echo "🚀 Starting Kubernetes deployment..."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot access Kubernetes cluster. Please check your connection."
    exit 1
fi

print_status "Kubernetes cluster is accessible"

# Create TLS certificates (self-signed for demo)
print_status "Creating TLS certificates..."
mkdir -p tls
if [ ! -f "tls/tls.crt" ] || [ ! -f "tls/tls.key" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout tls/tls.key \
        -out tls/tls.crt \
        -subj "/CN=frontend/O=frontend"
    print_status "TLS certificates created"
else
    print_status "TLS certificates already exist"
fi

# Create secrets and configmaps
print_status "Creating Kubernetes secrets and configmaps..."
kubectl create secret generic tls-certs --from-file tls/ --dry-run=client -o yaml | kubectl apply -f -
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf --dry-run=client -o yaml | kubectl apply -f -

# Deploy auth service
print_status "Deploying auth service..."
kubectl apply -f deployments/auth.yaml
kubectl apply -f services/auth.yaml

# Deploy hello service
print_status "Deploying hello service..."
kubectl apply -f deployments/hello.yaml
kubectl apply -f services/hello.yaml

# Deploy frontend service
print_status "Deploying frontend service..."
kubectl apply -f deployments/frontend.yaml
kubectl apply -f services/frontend.yaml

# Wait for deployments to be ready
print_status "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/auth
kubectl wait --for=condition=available --timeout=300s deployment/hello
kubectl wait --for=condition=available --timeout=300s deployment/frontend

# Get external IP
print_status "Getting external IP address..."
EXTERNAL_IP=""
while [ -z $EXTERNAL_IP ]; do
    print_warning "Waiting for external IP address..."
    EXTERNAL_IP=$(kubectl get svc frontend --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
    [ -z "$EXTERNAL_IP" ] && sleep 10
done

print_status "Deployment completed successfully! ✅"
echo ""
echo "🌐 Access your application at: https://$EXTERNAL_IP"
echo "📊 Check status with: kubectl get pods,svc"
echo "🔍 View logs with: kubectl logs -l app=[service-name]"
echo ""
echo "Next steps:"
echo "  - Test canary deployment: kubectl apply -f deployments/hello-canary.yaml"
echo "  - Test blue-green deployment: kubectl apply -f deployments/hello-green.yaml"