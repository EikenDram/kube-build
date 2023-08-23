#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.rabbitmq "Images" .Images.rabbitmq "Value" .Values.rabbitmq)}}

{{- define "install-pre"}}
    # generate secret
    kubectl create ns {{.Values.rabbitmq.helm.namespace}}
    kubectl -n {{.Values.rabbitmq.helm.namespace}} create secret generic rabbitmq-pass --from-literal=rabbitmq-password={{.Values.cluster.password}}
{{- end}}

{{- define "install-post"}}
    {{template "wait" dict "Name" "rabbitmq" "Namespace" .Value.helm.namespace}}
{{- end}}