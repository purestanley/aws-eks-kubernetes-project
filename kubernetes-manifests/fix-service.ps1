Write-Host "=== Fixing Kubernetes Service ===" -ForegroundColor Cyan

# 1. Delete existing service
Write-Host "1. Deleting existing service..." -ForegroundColor Yellow
kubectl delete svc purestanley-webapp-service -n purestanley-app 2>$null

Start-Sleep -Seconds 10

# 2. Create new service with correct configuration
Write-Host "2. Creating new service..." -ForegroundColor Yellow
@"
apiVersion: v1
kind: Service
metadata:
  name: purestanley-webapp-service
  namespace: purestanley-app
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
spec:
  selector:
    app: purestanley-webapp
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
  externalTrafficPolicy: Local
"@ | kubectl apply -f -

# 3. Wait for LoadBalancer
Write-Host "3. Waiting for LoadBalancer to provision (2 minutes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 120

# 4. Check status
Write-Host "4. Checking service status..." -ForegroundColor Yellow
kubectl get svc purestanley-webapp-service -n purestanley-app -o wide

# 5. Get URL
Write-Host "5. Getting service URL..." -ForegroundColor Yellow
$url = kubectl get svc purestanley-webapp-service -n purestanley-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>$null
if ($url) {
    Write-Host "   LoadBalancer URL: http://$url" -ForegroundColor Green
    "http://$url" | Set-Clipboard
    Write-Host "   URL copied to clipboard!" -ForegroundColor Green
} else {
    Write-Host "   LoadBalancer still provisioning..." -ForegroundColor Yellow
}
