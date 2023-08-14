#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.chartmuseum "Images" .Images.chartmuseum)}}

{{- define "init"}}
    # add ingress to chartmuseum to hosts
    echo "Adding chartmuseum's ingress to /etc/hosts"
    echo '{{.Values.server.ip}} {{.Values.chartmuseum.ingress}}.{{.Values.server.hostname | lower}}' >> /etc/hosts
{{- end}}

{{- define "install"}}
    # install from helm chart
    helm install {{.Values.chartmuseum.helm.name}} ./helm/{{.Version.dir}}/{{.Version.helm.name}}-{{.Version.helm.version}}.tgz  -f install/{{.Version.dir}}/{{.Values.chartmuseum.helm.values}} --namespace={{.Values.chartmuseum.helm.namespace}} --create-namespace
{{- end}}

{{- define "install-post"}}
    {{ template "wait" dict "Name" "chartmuseum" "Namespace" .Values.chartmuseum.helm.namespace}}

    # add helm repository from new chartmuseum server
    sleep 1
    helm repo add --username {{.Values.cluster.user}} --password {{.Values.cluster.password}} chartmuseum http://{{.Values.chartmuseum.ingress}}.{{.Values.server.hostname | lower}}/
    helm repo update
{{- end}}

{{- define "install-echo"}}
    echo "{{.Version.title}} installed to http://{{.Values.chartmuseum.ingress}}.{{.Values.server.hostname | lower}}"
{{- end}}

{{- define "upgrade"}}
    # 2D
{{- end}}

{{- define "uninstall"}}
    # uninstall from helm
    helm uninstall {{.Values.chartmuseum.helm.name}} -n {{.Values.chartmuseum.helm.namespace}}
    
    # namespace
    kubectl delete ns {{.Values.chartmuseum.helm.namespace}}
{{- end}}