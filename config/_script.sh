{{- define "script"}}
#
# help information
print_usage() 
{
    echo "
        Usage: sh {{.Version.dir}}.sh [-i/a/u/d/p/l] [-h]

        -i              Init {{.Version.dir}} (must be ran as root)
        -a              Install {{.Version.dir}}
        -u              Upgrade {{.Version.dir}}
        -d              Uninstall {{.Version.dir}}
        -p              Load packages for {{.Version.dir}} into docker registry
        -l              Load chart for {{.Version.dir}} into gitea
        
        -h              Help

        Without specifying any option script will load charts and packages, and then run install
    "
    exit
}

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

matches() {
    input="$1"
    pattern="$2"
    echo "$input" | grep -q "$pattern"
}

# read parameters
OBJECT=""
echo "Script for managing {{$.Version.title}} deployment"
while getopts iplaudh flag;
do
    case "${flag}" in
        i) OBJECT="<init>";;
        p) OBJECT="$OBJECT <package>";;
        l) OBJECT="$OBJECT <helm>" ;;
        a) OBJECT="$OBJECT <install>";;
        u) OBJECT="$OBJECT <upgrade>";;
        d) OBJECT="$OBJECT <uninstall>";;
        h) print_usage
        exit 1 ;;
    esac
done

# if no object is specified, upload packages and helm, then install
if [ -z "$OBJECT" ]; then
    OBJECT="<package> <helm> <install>"
fi

# check for necessary commands
check_cmd "kubectl"; if [ "$retval" = 1 ]; then exit 1; fi
check_cmd "grep"; if [ "$retval" = 1 ]; then exit 1; fi
check_cmd "helm" "optional" "helm charts can't be pushed"

if matches "$OBJECT" "<init>"; then
    # install
    echo "Initializing..."
    if [ 0 != $(id -u) ]; then echo "This section must be run as root"; exit 1; fi

    {{- if .Version.bin}}
    # binaries
    {{- range .Version.bin}}
    {{- if index . "usr-local-bin"}}
    # {{index . "usr-local-bin"}}
    echo "Installing {{index . "usr-local-bin"}} binary into /usr/local/bin/"
    mv bin/{{$.Version.dir}}/{{index . "usr-local-bin"}} /usr/local/bin/
    chown {{$.Values.server.user}}:{{$.Values.server.user}} /usr/local/bin/{{index . "usr-local-bin"}}
    chmod +x /usr/local/bin/{{index . "usr-local-bin"}}
    {{- end}}
    {{- end}}
    {{- end}}

    {{- block "init" . }}
    {{- end }}

    
    {{block "init-echo" .}}{{end}}echo "{{.Version.title}} initialized"
    #
fi

{{- if .Images}}
if matches "$OBJECT" "<package>"; then
    # images
    echo "Loading images into registry..."
    
    # create loader
    kubectl run loader --image={{.Values.loaders.packages}} --command -- sh -c 'while true; do sleep 10; done'
    kubectl wait --for=condition=ready pod -l run=loader

    {{- range .Images }}
    # {{.path}}/{{.name}}:{{.version}}
    echo "Loading image {{.path}}/{{.name}}:{{.version}} into private registry."
    kubectl cp packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar loader:/tmp
    kubectl exec -i loader -- skopeo copy {{if .sha}}--preserve-digest{{end}} --dest-creds {{$.Values.registry.user}}:{{$.Values.registry.password}} --dest-tls-verify=false --insecure-policy docker-archive:/tmp/{{.name}}-{{.version}}.tar docker://{{$.Values.server.hostname}}:5000/{{.path}}/{{.name}}:{{.version}}{{if .sha}}@sha256:{{.sha}}{{end}}

    {{- end }}
    {{- range .Version.dockerfile}}
    # custom {{.name}}:{{.version}}
    echo "Loading image {{.name}}:{{.version}} into private registry"
    kubectl cp packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar loader:/tmp
    kubectl exec -i loader -- skopeo copy --dest-creds {{$.Values.registry.user}}:{{$.Values.registry.password}} --dest-tls-verify=false --insecure-policy docker-archive:/tmp/{{.name}}-{{.version}}.tar docker://{{$.Values.server.hostname}}:5000/library/{{.name}}:{{.version}}
    
    {{- end}}
    # stop loader
    kubectl delete pod loader
    #
fi
{{- end}}

{{- with .Version.helm}}
if matches "$OBJECT" "<helm>"; then
    # helm
    echo "Loading helm chart {{.name}}-{{.version}}.tgz into chartmuseum"
    #helm cm-push "helm/{{$.Version.dir}}/{{.name}}-{{.version}}.tgz" chartmuseum
    #helm repo update > /dev/null
    curl --user "{{$.Values.cluster.user}}:{{$.Values.cluster.password}}"  --data-binary "@helm/{{$.Version.dir}}/{{.name}}-{{.version}}.tgz" http://{{$.Values.chartmuseum.ingress}}.{{$.Values.server.hostname | lower}}/api/charts
    echo ""
    #
fi
{{- end}}

if matches "$OBJECT" "<install>"; then
    # install
    echo "Installing..."
    {{- block "install-pre" .}}
    {{- end }}

    {{- block "install" . }}
    {{- end }}

    {{- if .Value }}
    {{- if .Value.helm }}
    # helm
    helm install {{.Value.helm.name}} chartmuseum/{{.Version.helm.name}} -f install/{{.Version.dir}}/{{.Value.helm.values}} --version {{.Version.helm.version}} --namespace={{.Value.helm.namespace}} --create-namespace
    {{- end }}
    {{- end }}

    {{- block "install-post" .}}
    {{- end }}

    {{block "install-echo" .}}{{end}}{{if .Value}}{{if .Value.ingress}}echo "{{.Version.title}} deployed on http://{{.Value.ingress}}.{{.Values.server.hostname | lower}}"{{end}}{{end}}
    #
fi

if matches "$OBJECT" "<upgrade>"; then
    # upgrade
    echo "Upgrading..."
    {{- block "upgrade-pre" .}}
    {{- end}}

    {{- block "upgrade" . }}
    {{- end }}

    {{- if .Value }}
    {{- if .Value.helm }}
    # helm
    helm upgrade {{.Value.helm.name}} chartmuseum/{{.Version.helm.name}} -f install/{{.Version.dir}}/{{.Value.helm.values}} --namespace={{.Value.helm.namespace}}
    {{- end }}
    {{- end }}

    {{- block "upgrade-post" . }}
    {{- end }}

    {{block "upgrade-echo" .}}{{end}}echo "{{.Version.title}} upgraded"
    #
fi

if matches "$OBJECT" "<uninstall>"; then
    # uninstall
    echo "Uninstalling..."
    {{- block "uninstall-pre" .}}
    {{- end}}

    {{- block "uninstall" . }}
    {{- end }}

    {{- if .Value }}
    {{- if .Value.helm }}
    # helm
    helm uninstall {{.Value.helm.name}} --namespace={{.Value.helm.namespace}}
    {{- end }}
    {{- end }}

    {{- block "uninstall-post" .}}
    {{- end}}

    {{block "uninstall-echo" .}}{{end}}echo "{{.Version.title}} uninstalled"
    #
fi
#
{{- end }}

{{- define "wait"}}
    # wait for pod to get ready
    echo "Waiting for pod to get ready..."
    sleep 3
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name={{.Name}} -n {{.Namespace}} --timeout=1m
{{- end}}

{{- define "etc-hosts"}}
    # add ingress to {{.ingress}} to hosts
    INGRESS="{{.Values.server.ip}} {{.ingress}}.{{.Values.server.hostname | lower}}"
    if grep -Fxq "$INGRESS" /etc/hosts
    then
        # found
        echo "Ingress already exists in /etc/hosts"
    else
        # not found
        echo "Adding {{.ingress}} ingress to /etc/hosts"
        echo "$INGRESS" >> /etc/hosts
    fi
{{- end}}