#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" (index .Version "registry-ui") "Images" (index .Images "registry-ui") "Value" (index .Values "registry-ui"))}}

{{- define "install-post"}}
    {{ template "wait" dict "Name" "docker-registry-ui" "Namespace" (index .Values "registry-ui" "helm" "namespace")}}

    echo "Registry uses self-signed certificate which will be disallowed in browser by default"
    echo "Go to http://{{.Values.server.hostname}}:5000 and allow insecure certificates to use Registry dashboard"
{{- end}}