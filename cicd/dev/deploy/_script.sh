#!/bin/sh

{{- template "script" (dict "Values" .Values "Version" .Version.dev "Images" .Images.dev "Value" .Values.dev)}}

{{- define "install"}}
    # add gitea admin to tea
    # generate token (because token generated with tea login add user and password wont have any scopes)
    TOKEN=curl "http://{{.Values.gitea.ingress}}.{{.Values.server.hostname | lower}}/api/v1/users/{{.Values.cluster.user}}/tokens" --silent --request POST --header 'Content-Type: application/json' --user "{{.Values.cluster.user}}:{{.Values.cluster.password}}" --data '{ "name": "tea", "scopes": [ "all" ] }' | jq -r '.sha1'

    # add login to tea
    tea login add --name=gitea --token=$TOKEN --url=http://{{.Values.gitea.ingress}}.{{.Values.server.hostname | lower}}/
    tea login default gitea

    # add new repo cluster-config
    tea repo create --name=cluster-config --init --description="Cluster configuration"

    # loaders: 
    # - working with git repo
    #kubectl run worker-git --image={{.Values.loaders.git}} --command -- sh -c 'while true; do sleep 10; done'
    #kubectl wait --for=condition=ready pod -l run=worker-git
    #kubectl cp <from> worker-git/tmp
    #kubectl exec -i worker-git -- <command>
    #kubectl delete pod worker-git
    # - loading npm packages to gitea
    #kubectl run loader-npm --image={{.Values.loaders.npm}} --command -- sh -c 'while true; do sleep 10; done'
    #kubectl wait --for=condition=ready pod -l run=loader-npm
    #kubectl cp <from> loader-npm/tmp
    #kubectl exec -i loader-npm -- <command>
    #kubectl delete pod loader-npm
    # - loading nuget packages to gitea
    #kubectl run loader-nuget --image={{.Values.loaders.nuget}} --command -- sh -c 'while true; do sleep 10; done'
    #kubectl wait --for=condition=ready pod -l run=loader-nuget
    #kubectl cp <from> loader-nuget/tmp
    #kubectl exec -i loader-nuget -- <command>
    #kubectl delete pod loader-nuget
{{- end}}

{{- define "install-echo"}}
    echo "2D"
    #{{- end}}