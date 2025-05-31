# Managing Deployments Using Kubernetes Engine

This project demonstrates advanced Kubernetes deployment strategies including rolling updates, canary deployments, and blue-green deployments. Based on Google Cloud Skills Boost lab exercises.

## Video

https://youtu.be/43Vb6TGdYa0

## Overview

This repository contains practical implementations of DevOps deployment patterns using Kubernetes Engine:
- **Rolling Updates**: Gradual deployment with zero downtime
- **Canary Deployments**: Testing new versions with subset of users
- **Blue-Green Deployments**: Instant switching between versions

## Prerequisites

- Google Cloud Platform account
- Basic understanding of Docker and Kubernetes
- Linux system administration knowledge
- DevOps and continuous deployment concepts

## Architecture

The project consists of three main components:
- **Auth service**: Authentication microservice
- **Hello service**: Main application service  
- **Frontend service**: Nginx frontend with TLS termination

## Quick Start

### 1. Setup Environment

```bash
# Set your working zone
gcloud config set compute/zone [YOUR_ZONE]

# Get the sample code
gsutil -m cp -r gs://spls/gsp053/orchestrate-with-kubernetes .
cd orchestrate-with-kubernetes/kubernetes

# Create Kubernetes cluster
gcloud container clusters create bootcamp \
  --machine-type e2-small \
  --num-nodes 3 \
  --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"
```

### 2. Deploy Initial Services

```bash
# Deploy auth service
kubectl create -f deployments/auth.yaml
kubectl create -f services/auth.yaml

# Deploy hello service
kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml

# Deploy frontend service
kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml
```

### 3. Verify Deployment

```bash
# Get external IP
kubectl get services frontend

# Test the application
curl -ks https://[EXTERNAL-IP]
```

## Deployment Strategies

### Rolling Updates

Rolling updates allow you to update your application with zero downtime by gradually replacing old pods with new ones.

```bash
# Scale deployment
kubectl scale deployment hello --replicas=5

# Update to new version
kubectl edit deployment hello
# Change image to: kelseyhightower/hello:2.0.0

# Monitor rollout
kubectl rollout status deployment/hello

# Rollback if needed
kubectl rollout undo deployment/hello
```

### Canary Deployments

Deploy new versions to a small subset of users to minimize risk.

```bash
# Create canary deployment
kubectl create -f deployments/hello-canary.yaml

# Verify traffic distribution (25% to canary)
curl -ks https://[EXTERNAL-IP]/version
```

The canary deployment runs alongside the stable version, receiving a portion of traffic based on the replica ratio.

### Blue-Green Deployments

Instantly switch between two complete environments.

```bash
# Create green deployment
kubectl create -f deployments/hello-green.yaml

# Switch service to green
kubectl apply -f services/hello-green.yaml

# Rollback to blue if needed
kubectl apply -f services/hello-blue.yaml
```

## Monitoring and Management

### Useful Commands

```bash
# View deployment status
kubectl get deployments
kubectl get pods
kubectl get services

# Check rollout history
kubectl rollout history deployment/hello

# Pause/Resume rollouts
kubectl rollout pause deployment/hello
kubectl rollout resume deployment/hello

# Scale deployments
kubectl scale deployment hello --replicas=[NUMBER]
```

### Troubleshooting

```bash
# Describe resources for detailed info
kubectl describe deployment [DEPLOYMENT-NAME]
kubectl describe pod [POD-NAME]

# View logs
kubectl logs [POD-NAME]

# Get events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## File Structure

```
├── README.md
├── deployments/
│   ├── auth.yaml
│   ├── hello.yaml
│   ├── hello-canary.yaml
│   ├── hello-green.yaml
│   └── frontend.yaml
├── services/
│   ├── auth.yaml
│   ├── hello.yaml
│   ├── hello-blue.yaml
│   ├── hello-green.yaml
│   └── frontend.yaml
├── nginx/
│   └── frontend.conf
└── tls/
    ├── tls.crt
    └── tls.key
```

## Key Concepts

### Deployments vs Services
- **Deployments**: Manage pod replicas and updates
- **Services**: Provide stable network endpoints

### Labels and Selectors
- Used to connect services to deployments
- Enable sophisticated routing for deployment strategies

### Health Checks
- **Liveness Probes**: Restart unhealthy containers
- **Readiness Probes**: Control traffic routing

## Best Practices

1. **Always use health checks** for production deployments
2. **Monitor rollouts** and be ready to rollback
3. **Test canary deployments** with real user traffic
4. **Plan resource requirements** for blue-green deployments
5. **Use labels effectively** for service routing

## Session Affinity

For canary deployments where user experience consistency is important:

```yaml
spec:
  sessionAffinity: ClientIP  # Users stick to same version
```

## Cleanup

```bash
# Delete deployments
kubectl delete deployment auth hello hello-canary hello-green frontend

# Delete services
kubectl delete service auth hello frontend

# Delete cluster
gcloud container clusters delete bootcamp
```

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine)
- [Kubernetes Deployment Strategies](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is based on Google Cloud Skills Boost labs and is intended for educational purposes.
