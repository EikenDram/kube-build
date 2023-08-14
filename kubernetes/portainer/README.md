# Installing Portainer

Think dashboard had better functionality, though for managing cluster k9s feels the best so far

## Images

```
portainer/portainer-ce:2.18.3
```

# Install

```sh
helm install portainer helm/portainer-1.0.43.tgz -f portainer/values.yaml -n portainer --create-namespace
```