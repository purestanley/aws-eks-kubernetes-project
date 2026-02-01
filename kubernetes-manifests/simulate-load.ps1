Write-Host "=== Horizontal Pod Autoscaling Test ===" -ForegroundColor Cyan

$namespace = "purestanley-app"

# 1. Initial State
Write-Host "`n1. Initial State:" -ForegroundColor Yellow
kubectl get pods -n $namespace
kubectl get hpa -n $namespace 2>$null || Write-Host "HPA not found yet" -ForegroundColor Red

# 2. Create HPA if not exists
Write-Host "`n2. Creating HPA..." -ForegroundColor Yellow
@"
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: purestanley-webapp-hpa
  namespace: $namespace
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: purestanley-webapp
  minReplicas: 2
  maxReplicas: 6
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 30
"@ | kubectl apply -f -

# 3. Check HPA
Write-Host "`n3. HPA Status:" -ForegroundColor Yellow
kubectl get hpa -n $namespace

# 4. Create Simple Load Test
Write-Host "`n4. Creating Load Test Job..." -ForegroundColor Yellow
@"
apiVersion: batch/v1
kind: Job
metadata:
  name: simple-load-test
  namespace: $namespace
spec:
  template:
    spec:
      containers:
      - name: loader
        image: alpine/curl:latest
        command: ["sh", "-c"]
        args:
        - |
          echo "Starting load test..."
          # Simple loop that makes HTTP requests
          for i in {1..1000}; do
            curl -s http://purestanley-webapp-service.$namespace.svc.cluster.local > /dev/null &
            sleep 0.05
          done
          wait
          echo "Load test completed!"
      restartPolicy: Never
  backoffLimit: 0
"@ | kubectl apply -f -

# 5. Monitor for 2 minutes
Write-Host "`n5. Monitoring Scaling (2 minutes)..." -ForegroundColor Yellow
Write-Host "   Press Ctrl+C to stop early" -ForegroundColor White

$endTime = (Get-Date).AddMinutes(2)
$counter = 0
while ((Get-Date) -lt $endTime) {
    $counter++
    Clear-Host
    Write-Host "=== Scaling Monitor - Update $counter ===" -ForegroundColor Cyan
    Write-Host "Time: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White
    
    Write-Host "`nPods:" -ForegroundColor Yellow
    kubectl get pods -n $namespace
    
    Write-Host "`nHPA Status:" -ForegroundColor Yellow
    kubectl get hpa -n $namespace
    
    Write-Host "`nJob Status:" -ForegroundColor Yellow
    kubectl get jobs -n $namespace
    
    try {
        Write-Host "`nResource Usage:" -ForegroundColor Yellow
        kubectl top pods -n $namespace 2>$null
    } catch {
        Write-Host "   Metrics not available yet" -ForegroundColor Gray
    }
    
    if ($counter -lt 8) {  # 8 updates * 15 seconds = 2 minutes
        Write-Host "`nNext update in 15 seconds..." -ForegroundColor Gray
        Start-Sleep -Seconds 15
    }
}

# 6. Cleanup
Write-Host "`n6. Cleaning up..." -ForegroundColor Yellow
kubectl delete job simple-load-test -n $namespace 2>$null

# 7. Final State
Write-Host "`n7. Final State:" -ForegroundColor Green
kubectl get pods -n $namespace
kubectl get hpa -n $namespace

Write-Host "`n✅ HPA Test Complete!" -ForegroundColor Green
Write-Host "Check HPA events: kubectl describe hpa purestanley-webapp-hpa -n $namespace" -ForegroundColor Cyan
