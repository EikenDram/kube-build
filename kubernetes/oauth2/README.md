# OAuth2

Reverse proxy

Will just add images into registry for using later

## Using oauth2-proxy with keycloak

Need to edit coredns configmap and add keycloak to hosts
```sh
kubectl edit cm/coredns -n kube-system
```
Kill coredns pod to refresh