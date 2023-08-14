#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.openebs "Images" .Images.openebs)}}

{{- define "init"}}
    # k3s config for disabling local-storage
    echo "Copying cfg-openebs.yaml to /etc/rancher/k3s/config.yaml.d/"
    mkdir /etc/rancher/k3s/config.yaml.d
    cp install/{{.Version.dir}}/cfg-openebs.yaml /etc/rancher/k3s/config.yaml.d/
{{- end}}

{{- define "install"}}
    # manifest
    kubectl apply -f manifest/{{.Version.dir}}/openebs-operator-lite.yaml 
    kubectl apply -f manifest/{{.Version.dir}}/openebs-lite-sc.yaml

    #Change default storage class
    kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
    kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    
    echo "{{.Version.title}} installed and set as default storage provider:"
    #Check that openebs is default now
    kubectl get storageclass
    echo "Reboot server to remove local-path from storage providers"
{{- end}}

{{- define "install-echo"}}
    #{{- end}}

{{- define "upgrade"}}
    # manifest
    kubectl apply -f manifest/{{.Version.dir}}/openebs-operator-lite.yaml 
    kubectl apply -f manifest/{{.Version.dir}}/openebs-lite-sc.yaml
    
    echo "{{.Version.title}} upgraded"
{{- end}}

{{- define "uninstall"}}
    # manifest
    kubectl delete -f manifest/{{.Version.dir}}/openebs-operator-lite.yaml 
    kubectl delete -f manifest/{{.Version.dir}}/openebs-lite-sc.yaml
    
    # namespace
    kubectl delete ns openebs
    
    echo "{{.Version.title}} uninstalled"
    echo "Probably shouldn't have uninstalled default storage provider"
{{- end}}