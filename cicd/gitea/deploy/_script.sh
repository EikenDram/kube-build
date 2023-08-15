#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.gitea "Images" .Images.gitea "Value" .Values.gitea)}}

{{- define "init"}}
    {{ template "etc-hosts" dict "Values" .Values "ingress" .Values.gitea.ingress }}
{{- end}}