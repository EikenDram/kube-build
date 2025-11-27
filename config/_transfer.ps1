#!/usr/bin/env pwsh

param(
    [string]$Name = "<all>",
    [switch]$Install,
    [switch]$Manifest,
    [switch]$Package,
    [switch]$Bin,
    [switch]$Script,
    [switch]$Helm,
    [switch]$Git,
    [switch]$BuildInfo,
    [switch]$Help
)

$COMPONENT = if ($Name -eq "<all>") { "<all>" } else { "<$Name>" }
$OBJECT = @()

# Help information
function Print-Usage {
    Write-Host @"
    Usage: ./transfer.ps1 [-Name <Component>] [-Install] [-Manifest] [-Package] [-Bin] [-Script] [-Helm] [-Git] [-BuildInfo] [-Help]

    -Name           Component to transfer. 
                    If not specified transfer all components

    -Install        Transfer install
    -Manifest       Transfer manifests
    -Package        Transfer docker images
    -Bin            Transfer binaries
    -Script         Transfer script
    -Helm           Transfer helm
    -Git            Transfer git

    -BuildInfo      Transfer build information

    -Help           Help

    Examples:
    - transfer everything
        ./transfer.ps1

    - transfer only gitea
        ./transfer.ps1 -Name gitea

    - transfer only ibmdb2 install files
        ./transfer.ps1 -Name ibmdb2 -Install

    - transfer k3s binaries and packages
        ./transfer.ps1 -Name k3s -Bin -Package
"@
    exit
}

# Check if command exists
function Check-Command {
    param(
        [string]$Command,
        [string]$Type = "required",
        [string]$Message = ""
    )
    
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return 0
    }
    catch {
        if ($Type -eq "optional") {
            Write-Warning "Warning: $Command does not exist, $Message"
            return 0
        }
        else {
            Write-Error "Error: $Command does not exist, install it before running script"
            return 1
        }
    }
}

# Check if pattern matches input
function Test-Match {
    param(
        [string]$Input,
        [string]$Pattern
    )
    return $Input -match [regex]::Escape($Pattern)
}

# Read parameters
Write-Host "Script for transferring deployment to server"

if ($Help) {
    Print-Usage
}

# Build object list based on switches
if ($Install) { $OBJECT += "<install>" }
if ($Manifest) { $OBJECT += "<manifest>" }
if ($Package) { $OBJECT += "<package>" }
if ($Bin) { $OBJECT += "<bin>" }
if ($Script) { $OBJECT += "<script>" }
if ($Helm) { $OBJECT += "<helm>" }
if ($Git) { $OBJECT += "<git>" }

if ($BuildInfo) {
    $OBJECT += "<log>"
    $COMPONENT = "<none>"
}

# If no object is specified, transfer all objects
if ($OBJECT.Count -eq 0) {
    Write-Host "Transferring component: $COMPONENT, object: all"
    if ($COMPONENT -eq "<all>") {
        $OBJECT = @("<install>", "<manifest>", "<package>", "<bin>", "<scripts>", "<helm>", "<git>", "<log>")
    }
    else {
        $OBJECT = @("<install>", "<manifest>", "<package>", "<bin>", "<script>", "<helm>", "<git>")
    }
}

# Ask confirmation if we're transferring everything
if ($COMPONENT -eq "<all>") {
    $choice = Read-Host "Continue (y/n)?"
    if ($choice -ne "y" -and $choice -ne "Y") {
        Write-Host "Exiting"
        exit 1
    }
}

# Transfer component, if directories exist
function Transfer-Component {
    param([string]$C)
    
    if ($COMPONENT -eq "<$C>" -or $COMPONENT -eq "<all>") {
        if ($OBJECT -contains "<bin>") {
            if ((Test-Path "bin/$C" -PathType Container) -and $C -ne "os") {
                Write-Host "$C binaries..."
                scp bin/$C/* "{{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/bin/$C/"
            }
        }
        
        if ($OBJECT -contains "<install>") {
            if (Test-Path "install/$C" -PathType Container) {
                Write-Host "$C install..."
                scp install/$C/* "{{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/install/$C/"
            }
        }
        
        if ($OBJECT -contains "<manifest>") {
            if (Test-Path "manifest/$C" -PathType Container) {
                Write-Host "$C manifests..."
                scp manifest/$C/* "{{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/manifest/$C/"
            }
        }
        
        if ($OBJECT -contains "<package>") {
            if (Test-Path "packages/$C" -PathType Container) {
                Write-Host "$C images..."
                scp packages/$C/* "{{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/packages/$C/"
            }
        }
        
        if ($OBJECT -contains "<script>") {
            Write-Host "$C script..."
            scp scripts/$C.sh "{{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/scripts/"
        }
        
        if ($OBJECT -contains "<helm>") {
            if (Test-Path "helm/$C" -PathType Container) {
                Write-Host "$C helm charts..."
                scp helm/$C/* "{{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/helm/$C/"
            }
        }
        
        if ($OBJECT -contains "<git>") {
            if (Test-Path "git/$C" -PathType Container) {
                Write-Host "$C git repositories..."
                scp git/$C/* "{{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/git/$C/"
            }
        }
    }
}

# Check for necessary commands
$result = Check-Command "scp"
if ($result -eq 1) { exit 1 }

Write-Host "Transferring:"

# Readme and build log
if ($OBJECT -contains "<log>") {
    Write-Host "Build information..."
    scp log/* "{{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/log/"
    scp README.md "{{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/"
}

if ($OBJECT -contains "<scripts>") {
    Write-Host "Scripts..."
    scp scripts/* "{{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/scripts/"
}

# Components
{{- range .Components}}
Transfer-Component "{{index $.Version .Name "dir"}}"
{{- end}}
