````markdown
# Kubernetes Manifests for ShopMicro Bootcamp Lab

This folder contains the Kubernetes manifests used by the lab and `scripts/deploy-k8s-lab.sh`.

Quick deploy steps (using Minikube):

```bash
# Start Minikube (if not running)
minikube start --memory=6144 --cpus=4 --disk-size=20g
minikube addons enable ingress
minikube addons enable metrics-server

# Build and load images (from repo root)
docker build -t shopmicro-backend:latest ./backend
docker build -t shopmicro-frontend:latest ./frontend
docker build -t shopmicro-ml-service:latest ./ml-service
minikube image load shopmicro-backend:latest
minikube image load shopmicro-frontend:latest
minikube image load shopmicro-ml-service:latest

# Apply manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmaps/
kubectl apply -f k8s/deployments/

# Wait for deployments
kubectl wait --for=condition=available --timeout=300s deployment --all -n shopmicro

# Port-forward to access UI
kubectl port-forward -n shopmicro svc/grafana 3000:3000 &
kubectl port-forward -n shopmicro svc/frontend 8080:3000 &
kubectl port-forward -n shopmicro svc/backend 3001:3001 &
```

Notes:

- Images are built locally and loaded into Minikube; deployments use `imagePullPolicy: Never` for the local workflow.
- If you are not using Minikube, set appropriate imagePullSecrets or push images to a registry.
- The manifests are intentionally simple for lab use (use `emptyDir` storage). For production, add PersistentVolumes and stronger security contexts.
````
