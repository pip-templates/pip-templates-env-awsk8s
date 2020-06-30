#!/usr/bin/env pwsh

param
(
    [Alias("c", "Path")]
    [Parameter(Mandatory=$false, Position=0)]
    [string] $ConfigPath
)

$ErrorActionPreference = "Stop"

# Load support functions
$path = $PSScriptRoot
if ($path -eq "") { $path = "." }
. "$($path)/../lib/include.ps1"
$path = $PSScriptRoot
if ($path -eq "") { $path = "." }

# Read config and resources
$config = Read-EnvConfig -Path $ConfigPath
$resources = Read-EnvResources -Path $ConfigPath

# Set default values for config parameters
Set-EnvConfigCommonDefaults -Config $config

# Delete namespace will remove all k8s components
Build-EnvTemplate -InputPath "$($path)/../templates/namespace_deployment.yml" -OutputPath "$($path)/../temp/namespace_deployment.yml" -Params1 $config -Params2 $resources
kubectl delete -f "$($path)/../temp/namespace_deployment.yml"
