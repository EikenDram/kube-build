#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" (index .Version "traefik-ui") "Images" (index .Images "traefik-ui"))}}

{{- define "init"}}
    # change traefik configuration
    # might not be necessary
    echo "Copying traefik-config.yaml to /var/lib/rancher/k3s/server/manifests/"
    cp install/traefik-ui/traefik-config.yaml /var/lib/rancher/k3s/server/manifests/
{{- end}}

{{- define "install"}}
    # service
    kubectl apply -f install/{{.Version.dir}}/dashboard.yaml

    # basic auth
    #kubectl apply -f install/{{.Version.dir}}/ingress-basic.yaml

    # keycloak auth
    kubectl apply -f install/{{.Version.dir}}/ingress-auth.yaml
{{- end}}

{{- define "install-echo"}}
    echo "{{.Version.title}} deployed on http://{{index .Values "traefik-ui" "ingress"}}.{{.Values.server.hostname | lower}}/dashboard/"
    #{{- end}}

{{- define "upgrade"}}
    # service
    kubectl apply -f install/{{.Version.dir}}/dashboard.yaml

    # basic auth
    #kubectl apply -f install/{{.Version.dir}}/ingress-basic.yaml

    # keycloak auth
    kubectl apply -f install/{{.Version.dir}}/ingress-auth.yaml
{{- end}}

{{- define "uninstall"}}
    # basic auth
    #kubectl delete -f install/{{.Version.dir}}/ingress-basic.yaml

    # keycloak auth
    kubectl delete -f install/{{.Version.dir}}/ingress-auth.yaml

    # service
    kubectl delete -f install/{{.Version.dir}}/dashboard.yaml
{{- end}}