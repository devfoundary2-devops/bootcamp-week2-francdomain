# Assessment Tests

### Test 1: Cluster Health

```bash
# All pods should be Running
kubectl get pods -n shopmicro
# Expected: All pods in Running state
```

![](./images/all-pods-run.png)

```bash
kubectl get deploy -n shopmicro
```

![](./images/deploy-run.png)

```bash
kubectl get svc -n shopmicro
```

![](./images/services-run.png)

### Test 2: Service Connectivity

```bash
# Test backend health
curl http://localhost:3001/health
# Expected: {"status":"healthy","timestamp":"..."}
```

![](./images/backend-health.png)

```bash
# Test frontend
curl http://localhost:8080
# Expected: HTML response
```

![](./images/frontend-html.png)

### Test 3: Metrics Collection

```bash
# Check backend metrics
curl http://localhost:3001/metrics | grep shopmicro_backend
# Expected: Prometheus metrics output
```

![](./images/backend-metrics.png)

### Test 4: Grafana Dashboards

```bash
# Access Grafana
open http://localhost:3000
# Login: admin/admin
# Expected: Dashboards with data
```

![](./images/dashboard.png)

**Metrics**

![](./images/metrics.png)

#### Prometheus UI

```bash
kubectl port-forward svc/prometheus -n shopmicro 9090:9090
```

![](./images/prom-portf.png)
![](./images/prom.png)

#### Frontend

```bash
kubectl port-forward svc/frontend -n shopmicro 8080:80
```

![](./images/fd-portf.png)
![](./images/frontend-gui.png)
