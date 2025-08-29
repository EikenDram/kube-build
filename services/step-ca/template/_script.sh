#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" ( index .Version "step-ca") "Images" (index .Images "step-ca") "Value" (index .Values "step-ca"))}}

{{- define "install-post"}}
    {{template "wait" dict "Name" "postgresql" "Namespace" .Value.helm.namespace}}
{{- end}}

{{- define "install-echo"}}
    echo "Step CA deployed on port: {{.Values "step-ca" "port"}}"
    #{{- end}}