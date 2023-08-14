{{- template "script" (dict "Values" .Values "Version" (index .Version "kube-home") "Images" (index .Images "kube-home"))}}

{{- define "install"}}
    # we'll need to run git-loader to run workload.sh
    kubectl run worker-git --image={{.Values.loaders.git}} --command -- sh -c 'while true; do sleep 10; done'
    kubectl wait --for=condition=ready pod -l run=worker-git
    kubectl cp install/{{.Version.dir}}/values.yaml worker-git:/tmp
    kubectl cp install/{{.Version.dir}}/workload.sh worker-git:/tmp
    kubectl exec -i worker-git -- sh /tmp/workload.sh
    kubectl delete pod worker-git
    
    # then make a new argocd application from application.yaml
    kubectl apply -f install/{{.Version.dir}}/application.yaml
{{- end}}

{{- define "install-echo"}}
    echo "{{.Version.title}} deployed as ArgoCD application"
{{- end}}

{{- define "upgrade"}}
    # 2D
{{- end}}

{{- define "uninstall"}}
    # delete argocd application
    kubectl delete -f install/{{.Version.dir}}/application.yaml
{{- end}}