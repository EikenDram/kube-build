#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.portainer "Images" .Images.portainer "Value" .Values.portainer)}}

{{- define "install-post"}}
{{ template "wait" dict "Name" "portainer" "Namespace" .Values.portainer.helm.namespace}}
{{- end}}

{{- define "install-echo"}}
    echo "{{.Version.title}} deployed on http://{{.Values.portainer.ingress}}.{{.Values.server.hostname | lower}}"
    echo "You need to access portainer through web and configure admin user before portainer goes into timeout mode"
    #{{- end}}

{{- define "uninstall-post" }}
    # delete namespace
    kubectl delete ns {{.Value.helm.namespace}}
{{- end}}