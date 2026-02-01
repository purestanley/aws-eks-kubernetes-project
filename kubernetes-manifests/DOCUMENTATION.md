# Task 4: Managing and Scaling Applications in Kubernetes

## 1. Horizontal Pod Autoscaling (HPA)

### Configuration:
- **Min Replicas:** 2
- **Max Replicas:** 10
- **CPU Threshold:** 50% utilization
- **Memory Threshold:** 70% utilization

### Files Created:
- `hpa.yaml` - HPA configuration
- `load-test.yaml` - Load generator deployment
- `simulate-load.ps1` - Automated test script

### Observed Behavior:
[Describe what happened during scaling:
- Initial pod count: 3
- During load test: Pods scaled up to X
- After load test: Pods scaled down to Y
- Time taken to scale up/down: Z seconds
- Metrics observed: CPU/Memory usage patterns]

### Screenshots:
1. HPA status before load test
2. HPA status during load test
3. HPA status after load test
4. Pod scaling events

## 2. Monitoring with Prometheus and Grafana

### Installation:
- Prometheus Stack installed via Helm
- Grafana with custom dashboards
- NGINX metrics exporter

### Access URLs:
- Grafana: http://[GRAFANA_URL] (admin/purestanley2024)
- Prometheus: http://[PROMETHEUS_URL]
- Local: http://localhost:3000 (Grafana), http://localhost:9090 (Prometheus)

### Dashboards Created:
1. **Kubernetes Cluster Dashboard**
   - Cluster CPU/Memory usage
   - Node status
   - Pod distribution

2. **Application Dashboard**
   - Application CPU/Memory usage
   - HTTP request rates
   - Pod count over time

### Screenshots:
1. Grafana login screen
2. Kubernetes cluster dashboard
3. Application monitoring dashboard
4. Prometheus query interface

## 3. Logging with EFK Stack

### Installation:
- Elasticsearch (1 replica)
- Kibana (LoadBalancer service)
- Fluentd (DaemonSet for log collection)

### Access URLs:
- Kibana: http://[KIBANA_URL]
- Local: http://localhost:5601

### Configuration:
- Fluentd collects logs from all containers
- Logs indexed in Elasticsearch
- Kibana for visualization and search

### Log Patterns Collected:
- Application logs (nginx access/error logs)
- System logs
- Kubernetes events

### Screenshots:
1. Kibana Discover view
2. Log search results
3. Log visualization dashboard
4. Index patterns configuration

## 4. Testing Methodology

### Load Test:
- Duration: 5 minutes
- Rate: 50 requests/second
- Tool: Vegeta load testing tool

### Monitoring During Test:
- Pod scaling observed in real-time
- Resource utilization tracked
- Log volume monitored

### Results:
[Document specific observations:
- Maximum pods reached: X
- Average CPU during load: Y%
- Memory usage pattern: Z
- Log entries generated: N entries/minute]

## 5. Challenges and Solutions

### Challenge 1: [Describe challenge]
**Solution:** [How you resolved it]

### Challenge 2: [Describe challenge]
**Solution:** [How you resolved it]

## 6. Cleanup Commands

```bash
# Delete monitoring stack
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring

# Delete logging stack
helm uninstall elasticsearch -n logging
helm uninstall kibana -n logging
kubectl delete namespace logging

# Delete HPA
kubectl delete hpa purestanley-webapp-hpa -n purestanley-app


## **Part 7: Quick Start Commands**

For your submission, include these commands:

```powershell
# 1. Set up HPA
kubectl apply -f hpa.yaml

# 2. Install monitoring
.\setup-monitoring-logging.ps1

# 3. Test scaling
.\test-scaling-monitoring.ps1

# 4. Access dashboards
Write-Host "Grafana: http://localhost:3000 (admin/purestanley2024)"
Write-Host "Kibana: http://localhost:5601"