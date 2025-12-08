#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.tekton "Images" .Images.tekton)}}

{{- define "install"}}
    # manifests
    kubectl apply -f manifest/{{.Version.dir}}/pipelines.yaml
    kubectl apply -f manifest/{{.Version.dir}}/triggers.yaml
    kubectl apply -f manifest/{{.Version.dir}}/interceptors.yaml
    kubectl apply -f manifest/{{.Version.dir}}/dashboard.yaml

    
    # Create htpasswd secret
    echo "Creating secrets"
    kubectl -n tekton-pipelines create secret generic tekton-auth-secret --from-file=htpasswd=./install/{{.Version.dir}}/htpasswd
    # ingress
    # basic auth
    kubectl apply -f install/{{.Version.dir}}/ingress.yaml

    # copy certificate to cert.yaml and apply it
    kubectl -n tekton-pipelines create configmap config-registry-cert --from-file=cert=cert/registry.pem
    kubectl -n tekton-pipelines label configmap config-registry-cert "app.kubernetes.io/instance=default"
    kubectl -n tekton-pipelines label configmap config-registry-cert "app.kubernetes.io/part-of=tekton-pipelines"
{{- end}}

{{- define "upgrade"}}
    # reapply manifests
    kubectl apply -f manifest/{{.Version.dir}}/pipelines.yaml
    kubectl apply -f manifest/{{.Version.dir}}/triggers.yaml
    kubectl apply -f manifest/{{.Version.dir}}/interceptors.yaml
    kubectl apply -f manifest/{{.Version.dir}}/dashboard.yaml
    kubectl apply -f install/{{.Version.dir}}/ingress-auth.yaml
{{- end}}

{{- define "uninstall"}}
    # manifest
    kubectl delete -f install/{{.Version.dir}}/ingress-auth.yaml
    kubectl delete -f manifest/{{.Version.dir}}/dashboard.yaml
    kubectl delete -f manifest/{{.Version.dir}}/interceptors.yaml
    kubectl delete -f manifest/{{.Version.dir}}/triggers.yaml
    kubectl delete -f manifest/{{.Version.dir}}/pipelines.yaml

    # configmap
    kubectl -n tekton-pipelines delete configmap config-registry-cert

    # namespace
    kubectl delete ns tekton-pipelines-resolvers
    kubectl delete ns tekton-pipelines
{{- end}}

