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

## Additional images

triggers.yaml
```yaml
args: ["-el-image", "gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/eventlistenersink:v0.24.1"]
```

pipelines.yaml
```yaml
"-git-image", "gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:v0.44.4", "-entrypoint-image", "gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/entrypoint:v0.44.4", "-nop-image", "gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/nop:v0.44.4", "-sidecarlogresults-image", "gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/sidecarlogresults:v0.44.4", "-imagedigest-exporter-image", "gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/imagedigestexporter:v0.44.4", "-pr-image", "gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/pullrequest-init:v0.44.4", "-workingdirinit-image", "gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/workingdirinit:v0.44.4",

"-gsutil-image", "gcr.io/google.com/cloudsdktool/cloud-sdk",

"-shell-image", "cgr.dev/chainguard/busybox",

"-shell-image-win", "mcr.microsoft.com/powershell:nanoserver"]
```
