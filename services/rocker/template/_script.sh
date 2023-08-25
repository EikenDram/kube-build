#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.rocker "Images" .Images.rocker "Value" .Values.rocker)}}

{{- define "install-post"}}
    echo "Use username 'rstudio' and password '{{.Values.cluster.password}}' to access RStudio"
{{- end}}