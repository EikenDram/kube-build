#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.athens "Images" .Images.athens "Value" .Values.athens)}}

{{- define "install-post"}}
    {{template "wait" dict "Name" "athens" "Namespace" .Value.helm.namespace}}
{{- end}}