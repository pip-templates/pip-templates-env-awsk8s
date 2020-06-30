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

# Install namespace
Build-EnvTemplate -InputPath "$($path)/../templates/namespace_deployment.yml" -OutputPath "$($path)/../temp/namespace_deployment.yml" -Params1 $config -Params2 $resources
kubectl apply -f "$($path)/../temp/namespace_deployment.yml"

# Install secret to access private docker repository
kubectl create secret docker-registry gitlab-docker-registry `
    --namespace="$($config.k8s_namespace)" `
    --docker-server="https://$($config.docker_registry)/v1/" `
    --docker-username="$($config.docker_user)" `
    --docker-password="$($config.docker_pass)" `
    --docker-email="$($config.docker_email)"

# Install configmaps
Build-EnvTemplate -InputPath "$($path)/../templates/configmaps_deployment.yml" -OutputPath "$($path)/../temp/configmaps_deployment.yml" -Params1 $config -Params2 $resources
kubectl apply -f "$($path)/../temp/configmaps_deployment.yml"

# Install secrets
Build-EnvTemplate -InputPath "$($path)/../templates/secrets_deployment.yml" -OutputPath "$($path)/../temp/secrets_deployment.yml" -Params1 $config -Params2 $resources -Secret
kubectl apply -f "$($path)/../temp/secrets_deployment.yml"

# Install pods
Build-EnvTemplate -InputPath "$($path)/../templates/pods_deployment.yml" -OutputPath "$($path)/../temp/pods_deployment.yml" -Params1 $config -Params2 $resources
kubectl apply -f "$($path)/../temp/pods_deployment.yml"

# Install services
Build-EnvTemplate -InputPath "$($path)/../templates/services_deployment.yml" -OutputPath "$($path)/../temp/services_deployment.yml" -Params1 $config -Params2 $resources
kubectl apply -f "$($path)/../temp/services_deployment.yml"

Write-EnvResources -Path $ConfigPath -Resources $resources
