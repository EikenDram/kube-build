#
{{- template "prepare" dict "Version" .Version.tekton "Images" .Images.tekton}}
#
if matches "<tekton> <all>" "$COMPONENT"; then
    if matches "$OBJECT" "<crypt>"; then
    # generate htpasswd
    echo "{{.Values.cluster.password}}" | htpasswd -c -B -i install/{{.Version.tekton.dir}}/htpasswd {{.Values.cluster.user}}
    fi
fi
#