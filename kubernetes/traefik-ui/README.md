# Traefik dashboard

For monitoring traefik

## Installing

Traefik already present in K3S, possibly need to enable dashboard in helm chart config, but i think it was already enabled?

What's left is to add service with middleware to auth
```sh
kubectl apply -f install/traefik-ui/dashboard.yaml
```