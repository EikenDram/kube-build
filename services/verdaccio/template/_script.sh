#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.verdaccio "Images" .Images.verdaccio "Value" .Values.verdaccio)}}

{{- define "install-post"}}
    {{template "wait" dict "Name" "verdaccio" "Namespace" .Value.helm.namespace}}
{{- end}}