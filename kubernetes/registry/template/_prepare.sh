#
{{- template "prepare" dict "Version" .Version.registry "Images" .Images.registry}}
#
if matches "<registry> <all>" "$COMPONENT"; then
    if matches "$OBJECT" "<crypt>"; then
    # generate htpasswd
    echo "{{.Values.registry.password}}" | htpasswd -c -B -i install/{{.Version.registry.dir}}/htpasswd {{.Values.registry.user}}
    fi
fi
#