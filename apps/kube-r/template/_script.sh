#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" (index .Version "kube-r") "Images" (index .Images "kube-r"))}}

{{- define "install"}}
    # 2D
{{- end}}

{{- define "upgrade"}}
    # 2D
{{- end}}

{{- define "uninstall"}}
    # 2D
{{- end}}