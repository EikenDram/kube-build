#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.dashboard "Images" .Images.dashboard "Value" .Values.dashboard)}}

{{- define "install-post"}}
    # access
    kubectl apply -f install/{{.Version.dir}}/access.yaml

    {{ template "wait" dict "Name" "kubernetes-dashboard-web" "Namespace" .Values.dashboard.helm.namespace}}

    # display long token
    sleep 1
    echo "Use this token to access dashboard:"
    kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
    echo ""
{{- end}}

{{- define "upgrade-post"}}
    # access
    kubectl apply -f install/{{.Version.dir}}/access.yaml

    # display long token
    sleep 2
    echo "Use this token to access dashboard:"
    kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d

    echo ""
{{- end}}

{{- define "uninstall-post"}}
    # delete access
    kubectl delete -f install/{{.Version.dir}}/access.yaml
    # delete namespace
    kubectl delete ns {{.Value.helm.namespace}}
{{- end}}