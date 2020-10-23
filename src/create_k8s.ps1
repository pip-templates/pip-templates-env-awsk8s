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

# Check for S3 bucket and create one if needed
$out = (aws s3api list-buckets --query "Buckets[].Name" --output="text") | Out-String
$buckets = $out.Replace("`n", "").Replace("`t", " ").Split(" ") | foreach($_) { "s3://" + $_ }
if (-not $buckets.Contains($config.k8s_s3_store)) {
    aws s3 mb $config.k8s_s3_store --region $config.aws_region | Out-Null
    Write-Host "Created S3 bucket for kops store $($config.k8s_s3_store)."
}

# Create k8s subnet
$out = aws ec2 create-subnet `
    --vpc-id $config.vpc `
    --cidr-block $config.k8s_network_cidr `
    --availability-zone $config.k8s_master_zones[0] | ConvertFrom-Json

$k8sSubnetId = $out.Subnet.SubnetId

# Create cluster
Write-Host "Creating Kubernetes cluster $($config.env_name)..."
kops create cluster `
    --yes `
    --cloud=aws `
    "--name=$($config.k8s_dns_zone)" `
    "--dns-zone=$($config.k8s_dns_zone)" `
    "--master-zones=$($config.k8s_master_zones -join ',')" `
    "--zones=$($config.k8s_node_zones -join ',')" `
    "--master-count=$($config.k8s_master_count)" `
    "--node-count=$($config.k8s_node_count)" `
    "--master-size=$($config.k8s_instance_type)" `
    "--node-size=$($config.k8s_instance_type)" `
    "--state=$($config.k8s_s3_store)" `
    "--image=$($config.k8s_ami)" `
    "--ssh-public-key=$($path)/../config/$($config.k8s_keypair_name).pub" `
    "--cloud-labels=Role=k8s,Environment=$($config.env_name)" `
    --encrypt-etcd-storage `
    "--subnets=$k8sSubnetId" `
    "--ssh-access=$($resources.mgmt_private_ip)/32" `
    --networking=weave `
    "--kubernetes-version=$($config.k8s_version)" `
    "--vpc=$($config.vpc)" `
    #--topology=private `
    #--dns=private `
    # --authorization=RBAC `

if ($LastExitCode -ne 0) {
    Write-Error "Error while creating k8s cluster. Watch logs above."
} else {
    # Wait until instances are created
    Write-Host "Waiting for $($config.env_name) cluster to start..."
    aws ec2 wait instance-running --region $config.aws_region --filters "Name=tag:Environment,Values=$($config.env_name)" "Name=tag:Role,Values=k8s"
}

# Read kubernetes IP addresses
while ($true) {
    $out = (aws ec2 describe-instances --region "$($config.aws_region)" --filters "Name=tag:Environment,Values=$($config.env_name)" "Name=tag:Role,Values=k8s" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].PrivateIpAddress" --output "text") | Out-String
    $k8s_nodes = $out.Replace("`n", "").Replace("`t", " ").Split(" ")
    if ($k8s_nodes.Length -gt 1) { break; }
    
    Write-Host "Did not find k8 nodes. Retrying..."
    Start-Sleep -Seconds 5
}

$out = (aws ec2 describe-subnets --region $config.aws_region --filters "Name=tag:KubernetesCluster,Values=$($config.k8s_dns_zone)" --query "Subnets[].SubnetId" --output "text") | Out-String
$env_subnet = $out.Replace("`n", "").Replace("`t", " ").Split(" ")[0]

$out = (aws ec2 describe-instances --region $config.aws_region --filters "Name=tag:KubernetesCluster,Values=$($config.k8s_dns_zone)" "Name=tag:Role,Values=k8s" "Name=instance-state-name,Values=running"  --query "Reservations[].Instances[].KeyName" --output "text") | Out-String
$env_keyname = $out.Replace("`n", "").Replace("`t", " ").Split(" ")[0]

Write-Host "K8s cluster $($config.env_name) was successfully created."

# Remove taint from master to launch containers
kubectl taint nodes $(kubectl get nodes --selector=kubernetes.io/role=master | tail -n 1 | cut -d " " -f 1) node-role.kubernetes.io/master-

# Write k8s resources
$resources.k8s_subnet = $k8sSubnetId
$resources.k8s_type = "kops"
$resources.k8s_nodes = @($k8s_nodes)
$resources.k8s_address = "api." + $config.k8s_dns_zone
$resources.k8s_keyname = $env_keyname

# Save resources
Write-EnvResources -Path $ConfigPath -Resources $resources
