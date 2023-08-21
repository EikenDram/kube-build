#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.prometheus "Images" .Images.prometheus "Value" .Values.prometheus)}}

{{- define "init"}}
    # k3s configuration for prometheus
    echo "Copying cfg-prometheus.yaml to /etc/rancher/k3s/config.yaml.d/"
    mkdir /etc/rancher/k3s/config.yaml.d
    cp install/{{.Version.dir}}/cfg-prometheus.yaml /etc/rancher/k3s/config.yaml.d/

    # restart k3s
    echo "Restarting K3S"
    systemctl restart k3s
{{- end}}

{{- define "install-post"}}
    # basic auth
    #kubectl apply -f install/{{.Version.dir}}/ingress-basic.yaml -n {{.Value.helm.namespace}}
    kubectl apply -f install/{{.Version.dir}}/ingress-auth.yaml -n {{.Value.helm.namespace}}

    {{ template "wait" dict "Name" "prometheus" "Namespace" .Values.prometheus.helm.namespace}}
    {{ template "wait" dict "Name" "grafana" "Namespace" .Values.prometheus.helm.namespace}}

    echo "Grafana deployed to http://{{.Values.grafana.ingress}}.{{.Values.server.hostname | lower}}/"
    echo "Grafana user is 'admin' with same password as cluster admin"
{{- end}}

{{- define "uninstall-post"}}
    # delete namespace
    kubectl delete ns {{.Value.helm.namespace}}
{{- end}}