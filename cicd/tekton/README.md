# Tekton

Continuous Integration/Continuous Delivery Pipelines

## Install

Install from manifests

Install dashboard ingress
```sh
k apply -f install/tekton/ingress.yaml
```

## @sha256

Had to modify manifests and remove all @sha from it, tried preserving @sha when using skopeo, but WSL's ubuntu's skopeo doesn't support the flag it seems

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