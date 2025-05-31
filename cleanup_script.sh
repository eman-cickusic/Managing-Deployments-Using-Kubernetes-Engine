#!/bin/bash

# Kubernetes Cleanup Script
# This script removes all deployed resources

set -e

echo "🧹 Starting cleanup process..."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Delete deployments
print_status "Deleting deployments..."
kubectl delete deployment auth --ignore-not-found=true
kubectl delete deployment hello --ignore-not-found=true
kubectl delete deployment hello-canary --ignore-not-found=true
kubectl delete deployment hello-green --ignore-not-found=true
kubectl delete deployment frontend --ignore-not-found=true

# Delete services
print_status "Deleting services..."
kubectl delete service auth --ignore-not-found=true
kubectl delete service hello --ignore-not-found=true
kubectl delete service frontend --ignore-not-found=true

# Delete secrets and configmaps
print_status "Deleting secrets and configmaps..."
kubectl delete secret tls-certs --ignore-not-found=true
kubectl delete configmap nginx-frontend-conf --ignore-not-found=true

print_status "Cleanup completed successfully! ✅"
echo "All resources have been removed from the cluster."