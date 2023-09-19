#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.gitea "Images" .Images.gitea "Value" .Values.gitea)}}

{{- define "init"}}
    {{ template "etc-hosts" dict "Values" .Values "Ingress" .Values.gitea.ingress }}
{{- end}}

{{- define "install-post"}}
    {{template "wait" dict "Label" "app" "Name" "gitea" "Namespace" .Value.helm.namespace}}

    sleep 5
    # add login to tea
    # generate token (because token generated with tea login add user and password wont have any scopes)
    tea login add --name=gitea --token=$(curl "http://{{.Values.gitea.ingress}}.{{.Values.server.hostname | lower}}/api/v1/users/{{.Values.cluster.user}}/tokens" --silent --request POST --header 'Content-Type: application/json' --user "{{.Values.cluster.user}}:{{.Values.cluster.password}}" --data '{ "name": "tea", "scopes": [ "all" ] }' | jq -r '.sha1') --url=http://{{.Values.gitea.ingress}}.{{.Values.server.hostname | lower}}/
    tea login default gitea

    # add new repo cluster-config
    tea repo create --name=cluster-config --init --description="Cluster configuration"
{{- end}}