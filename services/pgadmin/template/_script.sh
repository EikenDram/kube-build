#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.pgadmin "Images" .Images.pgadmin "Value" .Values.pgadmin)}}

{{- define "install-post"}}
    echo "Waiting for pod to get ready..."
    sleep 3
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name={{.Value.helm.name}} -n {{.Value.helm.namespace}} --timeout=5m
{{- end}}

{{- define "install-echo"}}
    echo "{{.Version.title}} deployed on port: {{.Values.pgadmin.port}}"
    echo "{{.Version.title}} deployed on http://{{index .Values "pgadmin" "ingress"}}.{{.Values.server.hostname | lower}}/"
    #{{- end}}