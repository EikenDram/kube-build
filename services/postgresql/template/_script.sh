#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.postgresql "Images" .Images.postgresql "Value" .Values.postgresql)}}

{{- define "install-post"}}
    {{template "wait" dict "Name" "postgresql" "Namespace" .Value.helm.namespace}}
{{- end}}

{{- define "install-echo"}}
    echo "PostgreSQL deployed on port: {{.Values.postgresql.port}}"
    #{{- end}}