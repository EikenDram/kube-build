#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" (index .Version "kube-app-template") "Images" (index .Images "kube-app-template") "Value" (index .Values "kube-app-template"))}}

{{- define "init"}}
    #init
{{- end}}

{{- define "install"}}
    # 2D
{{- end}}

{{- define "install-echo"}}
    echo "Custom message"
    #{{- end}}

{{- define "upgrade"}}
    # 2D
{{- end}}

{{- define "uninstall"}}
    # 2D
{{- end}}