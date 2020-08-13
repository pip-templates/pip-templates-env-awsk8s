#!/usr/bin/env pwsh

param
(
    [Alias("c", "Path")]
    [Parameter(Mandatory=$true, Position=0)]
    [string] $ConfigPath,
    [Parameter(Mandatory=$false, Position=1)]
    [string] $Baseline = ""
    
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

# Update configurations
Build-EnvTemplate -InputPath "$($path)/../templates/configmaps_deployment.yml" -OutputPath "$($path)/../temp/configmaps_deployment.yml" -Params1 $config -Params2 $resources
Build-EnvTemplate -InputPath "$($path)/../templates/secrets_deployment.yml" -OutputPath "$($path)/../temp/secrets_deployment.yml" -Params1 $config -Params2 $resources -Secret
#Build-EnvTemplate -InputPath "$($path)/../templates/services_deployment.yml" -OutputPath "$($path)/../temp/services_deployment.yml" -Params1 $config -Params2 $resources
Build-EnvTemplate -InputPath "$($path)/../templates/pods_deployment.yml" -OutputPath "$($path)/../temp/pods_deployment.yml" -Params1 $config -Params2 $resources

# Select kubectl context
kubectl config use-context $config.env_name

# Apply changes
kubectl apply -f "$($path)/../temp/configmaps_deployment.yml"
kubectl apply -f "$($path)/../temp/secrets_deployment.yml"
kubectl apply -f "$($path)/../temp/pods_deployment.yml"

# Update services if there are new
#kubectl apply -f "$($path)/../temp/services_deployment.yml"
