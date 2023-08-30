#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.jasper "Images" .Images.jasper "Value" .Values.jasper)}}

{{- define "init"}}
    #init
{{- end}}

{{- define "install-post"}}
{{ template "wait" dict "Name" "jasper" "Namespace" .Values.jasper.helm.namespace}}
{{- end}}

{{- define "install"}}
    # 2D
{{- end}}

{{- define "upgrade"}}
    # 2D
{{- end}}

{{- define "uninstall"}}
    # 2D
    
    # namespace
    kubectl delete ns {{.Values.jasper.helm.namespace}}
{{- end}}