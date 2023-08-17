#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.keycloak "Images" .Images.keycloak "Value" .Values.keycloak)}}

{{- define "install-post"}}
{{ template "wait" dict "Name" "keycloak" "Namespace" .Values.keycloak.helm.namespace}}
{{- end}}

{{- define "uninstall-post"}}
    # delete namespace
    kubectl delete ns {{.Value.helm.namespace}}
{{- end}}
