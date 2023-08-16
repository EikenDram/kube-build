#!/bin/sh
retval=-1
#check if command exists
check_cmd() {
    if ! command -v $1 > /dev/null 
    then
        if [ "$2" = "optional" ]; then
            echo Warning: $1 does not exist, $3
            retval=0
        else
            echo Error: $1 does not exist, install it before running script
            retval=1
        fi
    else
        retval=0
    fi
}

echo "Getting images from manifests, helm packages, .yaml files in install directory and .images from version.yaml..."

IMAGES="$1/images.yaml"
DEPLOYMENT="$1"

check_cmd "helm"; if [ "$retval" = 1 ]; then exit 1; fi
check_cmd "yq"; if [ "$retval" = 1 ]; then exit 1; fi

echo "### THIS FILE IS AUTO-GENERATED BY IMAGES.SH SCRIPT ###" > $IMAGES

{{- range .Components }}
    {{ template "component" dict "Version" (index $.Version .Name) "Value" (index $.Values .Name)}}
{{- end }}

{{define "component"}}
# {{.Version.title}}
echo "{{.Version.dir}}:" >> $IMAGES
{{- with .Version.helm}}
    echo "# helm template" >> $IMAGES
    {{- if and $.Value $.Value.helm}}
        helm images get {{.name}} $DEPLOYMENT/helm/{{$.Version.dir}}/{{.name}}-{{.version}}.tgz -f $DEPLOYMENT/install/{{$.Version.dir}}/{{$.Value.helm.values}} | sort -u | sed -e 's/^/- url: /' >> $IMAGES
    {{- else}}
        helm images get {{.name}} $DEPLOYMENT/helm/{{$.Version.dir}}/{{.name}}-{{.version}}.tgz | sort -u | sed -e 's/^/- url: /' >> $IMAGES
    {{- end}}
{{- end}}

{{- if .Version.manifest}}
echo "# manifest" >> $IMAGES
{{- range .Version.manifest}}
cat $DEPLOYMENT/manifest/{{$.Version.dir}}/{{.output}} | yq -N '..|.image? | select(.)' | sort -u | sed -e 's/^/- url: /' >> $IMAGES
{{- end}}
{{- end}}

{{- if .Version.images}}
echo "# images" >> $IMAGES
{{- range .Version.images}}
echo "- url: {{.host}}/{{.path}}/{{.name}}:{{.version}}{{if .sha}}@sha256:{{.sha}}{{end}}{{if .args}}@args:{{.args}}{{end}}" >> $IMAGES
{{- end}}
{{- end}}

echo "# install" >> $IMAGES
for f in install/{{.Version.dir}}/*.yaml
do
  # take action on each file. $f store current file name
  cat "$f" | yq -N '..|.image? | select(.)' | sort -u | sed -e 's/^/- url: /' >> $IMAGES
done

echo "" >> $IMAGES
{{end}}

# processes file
echo "Processing..."
./build images process --file=$IMAGES

echo "Images configuration retrieved to $IMAGES file"