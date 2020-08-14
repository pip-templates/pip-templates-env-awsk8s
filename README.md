# Overview

This is a built-in component to environment [pip-templates-env-master](https://github.com/pip-templates/pip-templates-env-master). 
This component stores scripts for management aws kubernetes environment.

# Usage

- Download this repository
- Copy *src* and *templates* folder to master template
- Add content of *config/config.k8s.json.add* to json config file from master template and set the required values

# Config parameters

Environment config variables description

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
