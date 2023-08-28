#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" (index .Version "kube-home") "Images" (index .Images "kube-home"))}}

{{- define "install"}}
    # we'll need to run git-loader to run workload.sh
    kubectl run worker-git --image={{.Values.loaders.git}} --command -- sh -c 'while true; do sleep 10; done'
    {{ template "wait" dict "Label" "run" "Name" "worker-git"}}
    kubectl cp install/{{.Version.dir}}/values.yaml worker-git:/tmp
    kubectl cp install/{{.Version.dir}}/logo.png worker-git:/tmp
    kubectl cp install/{{.Version.dir}}/workload.sh worker-git:/tmp
    kubectl exec -i worker-git -- sh /tmp/workload.sh
    kubectl delete pod worker-git --grace-period=1
    
    # then make a new argocd application from application.yaml
    kubectl apply -f install/{{.Version.dir}}/application.yaml
{{- end}}

{{- define "install-echo"}}
    echo "{{.Version.title}} deployed as ArgoCD application"
{{- end}}

{{- define "upgrade"}}
    # since cluster-config could have been adjusted manually after deployment
    echo "Manually update kube-home part of git repository cluster-config in gitea"

    # recreate argocd application
    kubectl delete -f install/{{.Version.dir}}/application.yaml
    sleep 3
    kubectl apply -f install/{{.Version.dir}}/application.yaml
{{- end}}

{{- define "uninstall"}}
    # delete argocd application
    kubectl delete -f install/{{.Version.dir}}/application.yaml
{{- end}}