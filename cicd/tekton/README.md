# Tekton

Continuous Integration/Continuous Delivery Pipelines

## Install

Install pipelines
```sh
k apply -f tekton/pipelines.yaml
```

Install triggers
```sh
k apply -f tekton/triggers.yaml
k apply -f tekton/interceptors.yaml
```

Install dashboard with ingress from `tekton.k3s.local`
```sh
k apply -f tekton/dashboard.yaml
k apply -f tekton/dashboard-ingress.yaml
```

Install CLI
```sh
sudo mv packages/tkn /usr/local/bin/
sudo chown core:core /usr/local/bin/tkn
sudo chmod +x /usr/local/bin/tkn
```

## Fixes

Alright, i had to modify manifests and remove all @sha from it, but could research into preserving @sha when using skopeo

## Error

When adding certificate directly into yaml need to add two tabs in each line

Need to switch to creating secret from file, should be better

## Error

During building a project there was an error:
```
failed to create fsnotify watcher: too many open files
```

Found this possible fix:
```sh
sysctl -w fs.inotify.max_user_watches=100000 
sysctl -w fs.inotify.max_user_instances=100000
```

Haven't tried it yet, seems to be working anyway