# Tekton Pipeline for Gitea Integration

Need to have registry cert:

```bash
# Create ConfigMap with cert key (required for SSL_CERT_DIR=/etc/ssl/certs)
kubectl create configmap config-registry-cert \
  --from-file=cert=/etc/rancher/k3s/certs/registry-ca.pem \
  -n devops

kubectl create configmap config-registry-cert \
  --from-file=cert=/etc/rancher/k3s/certs/registry-ca.pem \
  -n tekton-pipelines
```

Create gitea secret:

```bash
$secret = kubectl create secret generic gitea-credentials `
  --from-literal=username=k3sadmin `
  --from-literal=password=k3sadmin `
  -n devops `
  --type=kubernetes.io/basic-auth `
  --dry-run=client -o json | ConvertFrom-Json

$secret.metadata.annotations = @{"tekton.dev/git-0" = "http://gitea-http.gitea.svc.cluster.local:3000"}

$secret | ConvertTo-Json -Depth 10 | kubectl apply -f -
```

Apply tekton pipelines (shared will have RBAC for all devops pipelines):

```bash
kubectl apply -f .
```