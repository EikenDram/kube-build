#!/usr/bin/env pwsh

param(
    [string]$Component = "<all>",
    [switch]$Manifest,
    [switch]$Package,
    [switch]$Bin,
    [switch]$Helm,
    [switch]$Image,
    [switch]$Git,
    [switch]$Crypt,
    [switch]$Force,
    [switch]$Help
)

# Help information
function Print-Usage {
    @"
        Usage: pwsh prepare.ps1 [-Component Name] [-Manifest] [-Package] [-Bin] [-Helm] [-Image] [-Git] [-Crypt] [-Force] [-Help]

        -Component Name     Component (directory) to prepare.
                            If not specified prepare all components

        -Manifest           Prepare manifests
        -Package            Prepare docker images
        -Bin                Prepare binaries
        -Helm               Prepare helm charts
        -Image              Prepare custom docker images
        -Git                Prepare git repositories
        -Crypt              Prepare encryption

        -Force              Force download already existing files

        -Help               Show this help message

        Examples:
        - prepare everything
            pwsh prepare.ps1

        - prepare only gitea
            pwsh prepare.ps1 -Component gitea

        - prepare only ibmdb2 helm chart
            pwsh prepare.ps1 -Component ibmdb2 -Helm

        - prepare k3s binaries and images
            pwsh prepare.ps1 -Component gitea -Bin -Package

        - force redownload tekton images
            pwsh prepare.ps1 -Component tekton -Package -Force
"@
    exit 0
}

if ($Help) {
    Print-Usage
}

# Check if command exists
function Check-Command {
    param(
        [string]$Command,
        [string]$Type = "required",
        [string]$Message = ""
    )
    
    $exists = $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
    
    if (-not $exists) {
        if ($Type -eq "optional") {
            Write-Warning "Warning: $Command does not exist, $Message"
            return $false
        } else {
            Write-Error "Error: $Command does not exist, install it before running script"
            exit 1
        }
    }
    return $true
}

# String matching helper
function Test-Match {
    param(
        [string]$Component,
        [string]$ComponentList
    )
    # ComponentList is like "<tekton> <all>" or "<registry>"
    # We want to match if Component is "tekton" or "all"
    # Remove angle brackets and split by spaces
    $components = $ComponentList -replace '<|>', '' -split '\s+'
    $Component -in $components
}

# Build object list based on switches
$Object = @()
if ($Manifest) { $Object += "<manifest>" }
if ($Package) { $Object += "<package>" }
if ($Bin) { $Object += "<bin>" }
if ($Helm) { $Object += "<helm>" }
if ($Image) { $Object += "<image>" }
if ($Git) { $Object += "<git>" }
if ($Crypt) { $Object += "<crypt>" }

# If no object is specified, prepare all objects
if ($Object.Count -eq 0) {
    Write-Output "Preparing component: $Component, object: all"
    $Object = @("<crypt>", "<manifest>", "<package>", "<bin>", "<helm>", "<image>", "<git>")
    $ObjectStr = $Object -join " "
} else {
    $ObjectStr = $Object -join " "
    Write-Output "Preparing component: $Component, object: $ObjectStr"
}

# Ask confirmation if we're preparing everything
if ($Component -eq "<all>") {
    $confirmation = Read-Host "Continue (y/n)?"
    if ($confirmation -ne "y" -and $confirmation -ne "Y") {
        Write-Output "Exiting"
        exit 1
    }
}

# Check for necessary commands
Check-Command "curl"
Check-Command "tar"
Check-Command "helm" "optional" "helm charts can't be pulled"
Check-Command "docker" "optional" "docker images can't be downloaded"
Check-Command "git" "optional" "git repositories can't be pulled"

# Create directories if they don't exist
@("bin", "helm", "packages", "manifest", "git") | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

{{- define "prepare"}}
######################## {{$.Version.title}} #################################
if (Test-Match "<{{$.Version.dir}}> <all>" $Component) {
    Write-Output "Preparing {{$.Version.title}}..."
    {{- if .Version.bin}}
    if ($ObjectStr -match "<bin>") {
        # binaries
        if (-not (Test-Path "bin/{{$.Version.dir}}")) { New-Item -ItemType Directory -Path "bin/{{$.Version.dir}}" -Force | Out-Null }
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
        if ((-not (Test-Path "bin/{{$.Version.dir}}/{{$file}}")) -or $Force) {
            Write-Output "Downloading file {{.output}} from {{.url}}"
            Invoke-WebRequest -Uri "{{.url}}" -OutFile "bin/{{$.Version.dir}}/{{.output}}"
            {{- if .unpack }}
            Write-Output "Unpacking {{.output}}"
            if (-not (Test-Path "bin/unpack")) { New-Item -ItemType Directory -Path "bin/unpack" -Force | Out-Null }
            tar -xvf "bin/{{$.Version.dir}}/{{.output}}" -C "bin/unpack/"
            {{- if .unpack.extract}}
            Write-Output "Extracting {{.unpack.extract}}"
            Move-Item -Path "bin/unpack/{{.unpack.extract}}" -Destination "bin/{{$.Version.dir}}/" -Force
            {{- end }}
            {{- if .unpack.tar}}
            Write-Output "Zipping to {{.unpack.tar}}"
            tar -cf "bin/{{$.Version.dir}}/{{.unpack.tar}}" -C "bin/unpack/" .
            {{- end }}
            Remove-Item -Path "bin/unpack" -Recurse -Force
            Remove-Item -Path "bin/{{$.Version.dir}}/{{.output}}" -Force
            {{- end }}
        } else {
            Write-Output "File bin/{{$.Version.dir}}/{{$file}} exists, skipping"
        }
        {{- end }}
    }
    {{- end}}
    
    {{- if .Version.manifest}}
    if ($ObjectStr -match "<manifest>") {
        # manifest
        if (-not (Test-Path "manifest/{{$.Version.dir}}")) { New-Item -ItemType Directory -Path "manifest/{{$.Version.dir}}" -Force | Out-Null }
        {{- range .Version.manifest }}
        if ((-not (Test-Path "manifest/{{$.Version.dir}}/{{.output}}")) -or $Force) {
            Write-Output "Downloading manifest {{.output}} from {{.url}}"
            Invoke-WebRequest -Uri "{{.url}}" -OutFile "manifest/{{$.Version.dir}}/{{.output}}"
            {{- if index . "remove-sha"}}
            Write-Output "Removing all instances of '@sha256:[64 symbols]' from manifest"
            $content = Get-Content "manifest/{{$.Version.dir}}/{{.output}}"
            $content = $content -replace '@sha256:\w{64}', ''
            Set-Content -Path "manifest/{{$.Version.dir}}/{{.output}}" -Value $content
            {{- end}}
        } else {
            Write-Output "File manifest/{{$.Version.dir}}/{{.output}} exists, skipping"
        }
        {{- end }}
    }
    {{- end}}
    
    {{- with .Version.helm}}
    if ($ObjectStr -match "<helm>") {
        # helm
        if (-not (Test-Path "helm/{{$.Version.dir}}")) { New-Item -ItemType Directory -Path "helm/{{$.Version.dir}}" -Force | Out-Null }
        if ((-not (Test-Path "helm/{{$.Version.dir}}/{{.name}}-{{.version}}.tgz")) -or $Force) {
            Remove-Item -Path "helm/{{$.Version.dir}}/{{.name}}-{{.version}}.tgz" -Force -ErrorAction SilentlyContinue
            {{- if .pull}}
            Write-Output "Pulling helm chart {{.pull}}:{{.version}}"
            & helm pull {{.pull}} --version {{.version}} -d "helm/{{$.Version.dir}}"
            {{- else}}
            Write-Output "Pulling helm chart {{.repo}}/{{.name}}:{{.version}}"
            & helm repo add {{.repo}} {{.url}}
            & helm repo update | Out-Null
            & helm pull {{.repo}}/{{.name}} --version {{.version}} -d "helm/{{$.Version.dir}}"
            {{- end}}
        } else {
            Write-Output "File helm/{{$.Version.dir}}/{{.name}}-{{.version}}.tgz exists, skipping"
        }
    }
    {{- end}}
    
    {{- if .Images}}
    if ($ObjectStr -match "<package>") {
        # packages
        if (-not (Test-Path "packages/{{$.Version.dir}}")) { New-Item -ItemType Directory -Path "packages/{{$.Version.dir}}" -Force | Out-Null }
        {{- range .Images }}
        if ((-not (Test-Path "packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar")) -or $Force) {
            Write-Output "Downloading package {{if .path}}{{.path}}/{{end}}{{.name}}:{{.version}}"
            Remove-Item -Path "packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar" -Force -ErrorAction SilentlyContinue
            & docker pull {{.host}}/{{if .path}}{{.path}}/{{end}}{{.name}}:{{.version}}
            & docker save -o "packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar" {{.host}}/{{if .path}}{{.path}}/{{end}}{{.name}}:{{.version}}
        } else {
            Write-Output "File packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar exists, skipping"
        }
        {{- end }}
    }
    {{- end }}

    {{- if .Version.git}}
    if ($ObjectStr -match "<git>") {
        # git
        if (-not (Test-Path "git/{{$.Version.dir}}")) { New-Item -ItemType Directory -Path "git/{{$.Version.dir}}" -Force | Out-Null }
        {{- range .Version.git }}
        # always download repositories
        Write-Output "Downloading git repository {{.url}}"
        Remove-Item -Path "git/{{$.Version.dir}}/{{.name}}.tar.gz" -Force -ErrorAction SilentlyContinue
        & git clone {{.url}} "git/{{$.Version.dir}}/{{.name}}"
        tar -cvzf "git/{{$.Version.dir}}/{{.name}}.tar.gz" -C "git/{{$.Version.dir}}/{{.name}}" .
        Remove-Item -Path "git/{{$.Version.dir}}/{{.name}}" -Recurse -Force
        {{- end }}
    }
    {{- end }}

    {{- if .Version.dockerfile}}
    if ($ObjectStr -match "<image>") {
        # images
        if (-not (Test-Path "packages/{{$.Version.dir}}")) { New-Item -ItemType Directory -Path "packages/{{$.Version.dir}}" -Force | Out-Null }
        {{- range .Version.dockerfile}}
        if ((-not (Test-Path "packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar")) -or $Force) {
            Write-Output "Building docker image {{.name}}:{{.version}}"
            Remove-Item -Path "packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar" -Force -ErrorAction SilentlyContinue
            & docker build -t {{.name}}:{{.version}} "./install/{{$.Version.dir}}/{{if .file}}{{.file}}{{else}}Dockerfile{{end}}"
            & docker save -o "packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar" {{.name}}:{{.version}}
        } else {
            Write-Output "File packages/{{$.Version.dir}}/{{.name}}-{{.version}}.tar exists, skipping"
        }
        {{- end }}
    }
    {{- end }}
}
#
{{- end}}

#############################################################################
### Next part is assembled from _prepare.ps1 files in each build component ###
#############################################################################
#
