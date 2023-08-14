# Kube-R

Application for executing R scripts from RabbitMQ queue, used to provide report building service inside cluster. It has API for sending/retrieving  requests and UI for monitoring and managing requests

## Install

This will be installed as Argo CD application from helm chart and git repo kube-r-manifest with configuration:
- argo cd application manifest (application.yaml)
- kube-r helm chart
- kube-r docker images
- kube-r-manifest git repo with config
- kube-r git repo with source code (optional)