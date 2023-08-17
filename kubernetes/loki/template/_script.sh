#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.loki "Images" .Images.loki "Value" .Values.loki)}}

{{- define "install-echo"}}
    echo "Loki is deployed, add a new Loki data source in grafana with URL:"
    echo "http://loki.{{.Values.loki.helm.namespace}}:3100"
    echo "Import new dashboard to grafana from bin/loki/loki-dashboard.json"

    #{{- end}}

{{- define "install-post"}}
{{ template "wait" dict "Name" "loki" "Namespace" .Values.loki.helm.namespace}}
{{- end}}