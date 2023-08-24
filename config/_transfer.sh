#!/bin/sh

COMPONENT="<all>"
OBJECT=""

# help information
print_usage() 
{
    echo "
        Usage: sh transfer.sh [-n Name] [-i/m/p/b/s/l/e/g] [-h]

        -n Name         Component to transfer. 
                        If not specified transfer all components

        -i              Transfer install
        -m              Transfer manifests
        -p              Transfer docker images
        -b              Transfer binaries
        -s              Transfer script
        -l              Transfer helm
        -g              Transfer git

        -f              Transfer build information

        -h              Help

        Examples:
        - transfer everything
            sh transfer.sh

        - transfer only gitea
            sh transfer.sh -n gitea

        - transfer only ibmdb2 install files
            sh transfer.sh -n ibmdb2 -i

        - transfer k3s binaries and packages
            sh transfer.sh -n k3s -b -p
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
echo "Script for transferring deployment to server"
while getopts n:impbsflgh flag;
do
    case "${flag}" in
        n) COMPONENT="<${OPTARG}>";;
        i) OBJECT="$OBJECT <install>";;
        m) OBJECT="$OBJECT <manifest>";;
        p) OBJECT="$OBJECT <package>";;
        b) OBJECT="$OBJECT <bin>";;
        s) OBJECT="$OBJECT <script>";;
        f) OBJECT="$OBJECT <log>"
           COMPONENT="<none>";;
        l) OBJECT="$OBJECT <helm>";;
        g) OBJECT="$OBJECT <git>";;
        h) print_usage
        exit 1 ;;
        *) print_usage
        exit 1 ;;
    esac
done

# if no object is specified, transfer all objects
if [ -z "$OBJECT" ]; then
    echo Transferring component: ${COMPONENT}, object: all
    if [ "$COMPONENT" = "<all>" ]; then
        OBJECT="<install> <manifest> <package> <bin> <scripts> <helm> <git> <log>"
    else
        OBJECT="<install> <manifest> <package> <bin> <script> <helm> <git>"
    fi
else
    echo Transferring component: ${COMPONENT}, object: ${OBJECT}
fi

# Ask confirmation if we're transferring everything
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

# transfer component, if directories exist
transfer_component() {
C=$1
if matches "<$C> <all>" "$COMPONENT"; then
    if matches "$OBJECT" "<bin>"; then
        if [ -d "bin/$C" ] && [ "$C" != "os" ]; then
        echo "$C binaries..."
        scp bin/$C/* {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/bin/$C/
        fi
    fi
    if matches "$OBJECT" "<install>"; then
        if [ -d "install/$C" ]; then
        echo "$C install..."
        scp install/$C/* {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/install/$C/
        fi
    fi
    if matches "$OBJECT" "<manifest>"; then
        if [ -d "manifest/$C" ]; then
        echo "$C manifests..."
        scp manifest/$C/* {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/manifest/$C/
        fi
    fi
    if matches "$OBJECT" "<package>"; then
        if [ -d "packages/$C" ]; then
        echo "$C images..."
        scp packages/$C/* {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/packages/$C/
        fi
    fi
    if matches "$OBJECT" "<script>"; then
        echo "$C script..."
        scp scripts/$C.sh {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/scripts/
    fi
    if matches "$OBJECT" "<helm>"; then
        if [ -d "helm/$C" ]; then
        echo "$C helm charts..."
        scp helm/$C/* {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/helm/$C/
        fi
    fi
    if matches "$OBJECT" "<git>"; then
        if [ -d "git/$C" ]; then
        echo "$C git repositories..."
        scp git/$C/* {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/git/$C/
        fi
    fi
fi
}

# check for necessary commands
check_cmd "scp"; if [ "$retval" = 1 ]; then exit 1; fi

echo "Transferring:"

# Readme and build log
if matches "$OBJECT" "<log>"; then
    echo "Build information..."
    scp log/* {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/log/
    scp README.md {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/
fi

if matches "$OBJECT" "<scripts>"; then
    echo "Scripts..."
    scp scripts/* {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/scripts/
fi

# Components
{{- range .Components}}
transfer_component "{{index $.Version .Name "dir"}}"
{{- end}}