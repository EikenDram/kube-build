#!/bin/sh

COMPONENT="<all>"
OBJECT=""

# help information
print_usage() 
{
    echo "
        Usage: sh prepare.sh [-n Name] [-i/m/p/b/s/l/e/g/f] [-h]

        -n Name         Component (directory) to prepare. 
                        If not specified prepare all components

        -m              Prepare manifests
        -p              Prepare packages
        -b              Prepare binaries
        -l              Prepare helm
        -i              Prepare docker images
        -g              Prepare git repositories

        -f              Force redownload already existing files

        -h              Help

        Examples:
        - prepare everything
            sh prepare.sh

        - prepare only gitea
            sh prepare.sh -n gitea

        - prepare only ibmdb2 helm chart
            sh prepare.sh -n ibmdb2 -l

        - prepare k3s binaries and packages
            sh prepare.sh -n gitea -b -p
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
FORCE=0
while getopts n:pmblhigf flag;
do
    case "${flag}" in
        n) COMPONENT="<${OPTARG}>";;
        m) OBJECT="$OBJECT <manifest>";;
        p) OBJECT="$OBJECT <package>";;
        b) OBJECT="$OBJECT <bin>";;
        l) OBJECT="$OBJECT <helm>";;
        i) OBJECT="$OBJECT <image>";;
        g) OBJECT="$OBJECT <git>";;
        f) FORCE=1;;
        h) print_usage
        exit 1 ;;
        *) print_usage
        exit 1 ;;
    esac
done

# if no object is specified, prepare all objects
if [ -z "$OBJECT" ]; then
    echo Preparing component: ${COMPONENT}, object: all
    OBJECT="<manifest> <package> <bin> <helm> <image> <git>"
else
    echo Preparing component: ${COMPONENT}, object: ${OBJECT}
fi

# Ask confirmation if we're preparing everything
if [ "$COMPONENT" = "<all>" ]; then
    read -p "Continue (y/n)?" choice
    case "$choice" in 
    y|Y ) ;;
    n|N ) echo "Exiting"
        exit 1;;
    * ) echo "Exiting"
        exit 1;;
    esac
fi

{{- define "prepare"}}
######################## {{$.Version.title}} #################################
if matches "<{{$.Version.dir}}> <all>" "$COMPONENT"; then
    echo "Preparing {{$.Version.title}}..."
    {{- if .Version.bin}}
    if matches "$OBJECT" "<bin>"; then
        # binaries
        if [ ! -d "bin/{{$.Version.dir}}" ]; then mkdir bin/{{$.Version.dir}}; fi
        {{- range .Version.bin }}
        {{- $file := .output}}
        {{- if .unpack}}
            {{- if .unpack.extract}}
                {{- $file = .unpack.extract | base}}
            {{- end}}
            {{- if .unpack.tar}}
                {{- $file = .unpack.tar}}
            {{- end}}
        {{- end}}
        if [ ! -f "bin/{{$.Version.dir}}/{{$file}}" ] || [ $FORCE = 1 ]; then
            echo "Downloading file {{.output}} from {{.url}}"
            curl -L {{.url}} --output bin/{{$.Version.dir}}/{{.output}}
            {{- if .unpack }}
            echo "Unpacking {{.output}}"
            mkdir bin/unpack
            tar -xvf bin/{{$.Version.dir}}/{{.output}} -C bin/unpack/
            {{- if .unpack.extract}}
            echo "Extracting {{.unpack.extract}}"
            mv bin/unpack/{{.unpack.extract}} bin/{{$.Version.dir}}/
            {{- end }}
            {{- if .unpack.tar}}
            echo "Unzipping to {{.unpack.tar}}"
            tar -cf bin/{{$.Version.dir}}/{{.unpack.tar}} -C bin/unpack/ .
            {{- end }}
            rm -rf bin/unpack
            rm bin/{{$.Version.dir}}/{{.output}}
            {{- end }}
        else
            echo "File bin/{{$.Version.dir}}/{{$file}} exists, skipping"
        fi
        {{- end }}
    fi
    {{- end}}
    
    {{- if .Version.manifest}}
    if matches "$OBJECT" "<manifest>"; then
        # manifest
        if [ ! -d "manifest/{{$.Version.dir}}" ]; then mkdir manifest/{{$.Version.dir}}; fi
        {{- range .Version.manifest }}
        if [ ! -f "manifest/{{$.Version.dir}}/{{.output}}" ] || [ $FORCE = 1 ]; then
            echo "Downloading manifest {{.output}} from {{.url}}"
            curl -L {{.url}}  --output manifest/{{$.Version.dir}}/{{.output}}
            {{- if index . "remove-sha"}}
            echo "Removing all instances of '@sha256:[64 symbols]' from manifest" 
            sed -i 's/\(@sha256:.\{64\}\)//g' manifest/{{$.Version.dir}}/{{.output}}
            {{- end}}
        else
            echo "File manifest/{{$.Version.dir}}/{{.output}} exists, skipping"
        fi
        {{- end }}
    fi
    {{- end}}
    
    {{- with .Version.helm}}
    if matches "$OBJECT" "<helm>"; then
        # helm
        if [ ! -d "helm/{{$.Version.dir}}" ]; then mkdir helm/{{$.Version.dir}}; fi
        if [ ! -f "helm/{{$.Version.dir}}/{{.name}}-{{.version}}.tgz" ] || [ $FORCE = 1 ]; then
            rm -f helm/{{$.Version.dir}}/{{.name}}-{{.version}}.tgz
            {{- if .pull}}
            echo "Pulling helm chart {{.pull}}:{{.version}}"
            helm pull {{.pull}} --version {{.version}} -d helm/{{$.Version.dir}}
            {{- else}}
            echo "Pulling helm chart {{.repo}}/{{.name}}:{{.version}}"
            helm repo add {{.repo}} {{.url}}
            helm repo update > /dev/null
            helm pull {{.repo}}/{{.name}} --version {{.version}} -d helm/{{$.Version.dir}}
            {{- end}}
        else
            echo "File helm/{{$.Version.dir}}/{{.name}}-{{.version}}.tgz exists, skipping"
        fi
    fi
    {{- end}}
    
    {{- if .Images}}
    if matches "$OBJECT" "<package>"; then
        # packages
        if [ ! -d "packages/{{$.Version.dir}}" ]; then mkdir packages/{{$.Version.dir}}; fi
        {{- range .Images }}
        if [ ! -f "packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar" ] || [ $FORCE = 1 ]; then
            echo "Downloading package {{.path}}/{{.name}}:{{.version}}"
            rm -f packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar
            skopeo copy {{if .sha}}--preserve-digests{{end}} docker://{{.host}}/{{.path}}/{{.name}}:{{.version}}{{if .sha}}@sha256:{{.sha}}{{end}} docker-archive:./packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar:{{.path}}/{{.name}}:{{.version}}{{if .sha}}@sha256:{{.sha}}{{end}} {{if .args}} {{.args}} {{end}}
        else
            echo "File packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar exists, skipping"
        fi
        {{- end }}
    fi
    {{- end }}

    {{- if .Version.git}}
    if matches "$OBJECT" "<git>"; then
        # git
        if [ ! -d "git/{{$.Version.dir}}" ]; then mkdir git/{{$.Version.dir}}; fi
        {{- range .Version.git }}
        # always download repositories
        echo "Downloading git repository {{.url}}"
        rm -f git/{{$.Version.dir}}/{{.name}}.tar.gz
        git clone {{.url}} git/{{$.Version.dir}}/{{.name}}
        tar -cvzf git/{{$.Version.dir}}/{{.name}}.tar.gz -C git/{{$.Version.dir}}/{{.name}} .
        rm -rf git/{{$.Version.dir}}/{{.name}}
        {{- end }}
    fi
    {{- end }}

    {{- if .Version.dockerfile}}
    if matches "$OBJECT" "<image>"; then
        # images
        if [ ! -d "packages/{{$.Version.dir}}" ]; then mkdir packages/{{$.Version.dir}}; fi
        {{- range .Version.dockerfile}}
        if [ ! -f "packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar" ] || [ $FORCE = 1 ]; then
            echo Building docker image {{.name}}:{{.version}}
            rm -f packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar
            podman build -t {{.name}}:{{.version}} ./install/{{$.Version.dir}}/{{if .file}}{{.file}}{{else}}Dockerfile{{end}}
            skopeo copy containers-storage:localhost/{{.name}}:{{.version}} docker-archive:./packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar:{{.name}}:{{.version}}
        else
            echo "File packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar exists, skipping"
        fi
        {{- end }}
    fi
    {{- end }}
fi
#
{{- end}}

# check for necessary commands
check_cmd "curl"; if [ "$retval" = 1 ]; then exit 1; fi
check_cmd "tar"; if [ "$retval" = 1 ]; then exit 1; fi
check_cmd "grep"; if [ "$retval" = 1 ]; then exit 1; fi
check_cmd "skopeo" "optional" "docker images can't be downloaded"
check_cmd "helm" "optional" "helm charts can't be pulled"
check_cmd "podman" "optional" "custom docker images can't be created"
check_cmd "git" "optional" "git repositories can't be pulled"

# create directories if don't exist
if [ ! -d "bin" ]; then mkdir bin; fi
if [ ! -d "helm" ]; then mkdir helm; fi
if [ ! -d "packages" ]; then mkdir packages; fi
if [ ! -d "manifest" ]; then mkdir manifest; fi
if [ ! -d "git" ]; then mkdir git; fi

############################################################################
### Next part is assebled from _prepare.sh files in each build component ###
############################################################################
#