# Kube-Home

Home page for our cluster containing information about cluster with descriptions and links to all deployed applications

## Install

This will be installed as Argo CD application from helm chart and git repo kube-home-manifest with configuration:
- argo cd application manifest (application.yaml)
- kube-home helm chart
- kube-home docker image
- kube-home-manifest git repo with values.yaml
- kube-home git repo with source code