#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.gitea "Images" .Images.gitea "Value" .Values.gitea)}}

{{- define "init"}}
    # add ingress to gitea to hosts
    echo "Adding gitea's ingress to /etc/hosts"
    echo '{{.Values.server.ip}} {{.Values.gitea.ingress}}.{{.Values.server.hostname | lower}}' >> /etc/hosts
{{- end}}