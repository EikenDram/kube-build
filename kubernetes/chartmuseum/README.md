# Chartmuseum

Helm chart repository server

Couldn't get `helm pull` to work from inside of cluster with Gitea helm repo when accessing via service URL, it was redirecting to ingress and failing to discover it; so switched to chartmuseum

## Install

Install from helm chart