# Overview

The Environment Management scripts are used to create, update or delete operating environments.
The environments support types: cloud. 
Depending on requirements, they can be used for development, testing and production.

The scriptable environments follow "Infrastructure as a Code" principles and allow to:
* Have controllable and verifiable environment structure
* Quickly spin up fully-functional environments in minutes
* Minimize differences between environments
* Provide developers with environment to run and test their components integrated into the final system and expand their area of responsibilities

# Usage

Environment management scripts should be executed from management station. Management station can be created by create_mgmt.ps1 script

`
./cloud/create_mgmt.ps1 -c <path to config file>
`

This script will create cloud virtual machine and copy environment management project to /home/ubuntu/pip-templates-envmgmt

Before you can run environment management scripts you must install prerequisites. That step is required to be done once:

`
./install_prereq_<os>.ps1
`

To create a new environment prepare an environment configuration file (see below) and execute the following script:

`
./create_env.ps1 -c <path to config file>
`

As the result, the script will create the environment following your spec and place addresses of the created resources
into a resource file in the same folder where config file is located.

Deleting environment can be done as:

`
./destroy_env.ps1 -c <path to config file>
`

It is possible to execute individual phases of the process by running specific scripts.
For instance, you can create only kubernetes cluster or database, or install kubernetes components by running scripts from *cloud* folder by executing script with -c parameter.

# Project structure
| Folder | Description |
|----|----|
| Cloud | Scripts related to management cloud environment. |  
| Config | Config files for scripts. Store *example* configs for each environment, recommendation is not change this files with actual values, set actual values in duplicate config files without *example* in name. Also stores *resources* files, created automaticaly. | 
| Lib | Scripts with support functions like working with configs, templates etc. | 
| Temp | Folder for storing automatically created temporary files. | 
| Templates | Folder for storing templates, such as kubernetes yml files, cloudformation templates, etc. | 

### Cloud environment

* Cloud env config parameters

| Variable | Default value | Description |
|----|----|---|
| aws_access_id | XXX | AWS id for access resources |
| aws_access_key | XXX | AWS key for access resources |
| aws_region | us-east-1 | AWS region where resources will be created |
| env_name | pip-templates-stage | Name of environment |
| vpc | vpc-bb755cc1 | Amazon Virtual Private Cloud name where resources will be created |
| mgmt_subnet_cidr | 172.31.100.0/28 | MGMT station subnet address pool |
| mgmt_subnet_zone | us-east-1a | MGMT station subnet zone |
| mgmt_ssh_allowed_cidr_blocks | [109.254.10.81/32, 46.219.209.174/32] | MGMT station address pool allowed to SSH |
| mgmt_instance_type | t2.medium | MGMT station vm type |
| mgmt_instance_keypair_new | true | Switch for creation new ssh key. If set to *true* - then key pair will be added to AWS |
| mgmt_instance_keypair_name | ecommerce | MGMT station vm keypair |
| mgmt_instance_username | ubuntu | MGMT station vm username |
| mgmt_instance_ami | ami-43a15f3e | MGMT station vm aws image |
| k8s_version | 1.17.0 | Kubernetes cluster version |
| k8s_s3_store | s3://test.templates.com | Kubernetes cluster aws storage (required for kops files) |
| k8s_dns_zone | test.templates.com | Kubernetes cluster dns zone |
| k8s_master_zones | us-east-1a | KKubernetes master aws zone/region |
| k8s_node_zones | us-east-1a | Kubernetes node aws zone/region |
| k8s_master_count | 1 | Kubernetes cluster master count |
| k8s_node_count | 1 | Kubernetes cluster node count |
| k8s_instance_type | t2.medium | Kubernetes cluster instance type |
| k8s_ami | ami-43a15f3e | Kubernetes cluster aws image |
| k8s_keypair_name | ecommerce | Kubernetes cluster keypair |
| k8s_network_cidr | 10.1.0.0/24 | Kubernetes cluster address pool |
| k8s_namespace | templates-devs | Kubernetes components namespace |
| docker_registry | https://docker.registry.address | Docker registry host |
| docker_user | pip-templates | Docker registry credentials username |
| docker_pass | XXX | Docker registry credentials password |
| docker_email | piptemplates@gmail.com | Docker registry credentials password |
