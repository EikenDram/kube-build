#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.dev "Images" .Images.dev "Value" .Values.dev)}}

{{- define "install"}}
    kubectl create namespace {{.Values.dev.namespace}}

    # create configmap for registry certs
    kubectl create configmap config-registry-cert \
    --from-file=cert=/etc/rancher/k3s/certs/registry-ca.pem \
    -n {{.Values.dev.namespace}}

    kubectl create configmap config-registry-cert \
    --from-file=cert=/etc/rancher/k3s/certs/registry-ca.pem \
    -n tekton-pipelines

    # create secret for gitea credentials
    $secret = kubectl create secret generic gitea-credentials `
    --from-literal=username={{.Values.cluster.user}} `
    --from-literal=password={{.Values.cluster.password}} `
    -n {{.Values.dev.namespace}} `
    --type=kubernetes.io/basic-auth `
    --dry-run=client -o json | ConvertFrom-Json

    $secret.metadata.annotations = @{"tekton.dev/git-0" = "http://gitea-http.{{.Values.gitea.ingress}}.svc.cluster.local:3000"}

    $secret | ConvertTo-Json -Depth 10 | kubectl apply -f -

    kubectl apply -n {{.Values.dev.namespace}} -f install/{{.Version.dir}}/rbac.yaml
    kubectl apply -n {{.Values.dev.namespace}} -f install/{{.Version.dir}}/task-build-dotnet.yaml
    kubectl apply -n {{.Values.dev.namespace}} -f install/{{.Version.dir}}/task-build-go.yaml
    kubectl apply -n {{.Values.dev.namespace}} -f install/{{.Version.dir}}/task-build-pnpm.yaml
    kubectl apply -n {{.Values.dev.namespace}} -f install/{{.Version.dir}}/task-clone-repo.yaml
    kubectl apply -n {{.Values.dev.namespace}} -f install/{{.Version.dir}}/task-docker-build.yaml
{{- end}}

{{- define "install-echo"}}
    echo "2D"
    #{{- end}}