#
{{- template "prepare" dict "Version" .Version.os "Images" .Images.os}}
#

{{- if .Values.server.admin.enabled}}
if matches "<os> <all>" "$COMPONENT"; then
    if matches "$OBJECT" "<crypt>"; then
    # 
    # generate password hash for admin user
    passhash=$(mkpasswd {{.Values.server.admin.password}})
    sed -i "s|__passhash__|$passhash|gi" install/{{.Version.os.dir}}/coreos.yaml
    echo "Password hash for admin set"
    #
    fi
fi
{{- end}}

