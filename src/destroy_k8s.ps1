#!/usr/bin/env pwsh

param
(
    [Alias("c", "Path")]
    [Parameter(Mandatory=$true, Position=0)]
    [string] $ConfigPath,
    [Alias("p")]
    [Parameter(Mandatory=$false, Position=1)]
    [string] $Prefix
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

# Configure AWS cli
$env:AWS_ACCESS_KEY_ID = $config.aws_access_id
$env:AWS_SECRET_ACCESS_KEY = $config.aws_access_key 
$env:AWS_DEFAULT_REGION = $config.aws_region 

# Set environment variables
$env:KOPS_STATE_STORE = $config.k8s_s3_store

# Delete cluster
kops delete cluster `
    --state $config.k8s_s3_store `
    --name $config.k8s_dns_zone `
    --yes

# Delete subnet 
aws ec2 delete-subnet --subnet-id $resources.k8s_subnet

# Write k8s resources
$resources.k8s_type = $null
$resources.k8s_nodes = @()
$resources.k8s_address = $null
$resources.k8s_subnet = $null
$resources.k8s_keyname = $null

# Save resources
Write-EnvResources -Path $ConfigPath -Resources $resources
