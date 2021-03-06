# Overview

This is a built-in module to environment [pip-templates-env-master](https://github.com/pip-templates/pip-templates-env-master). 
This module stores scripts for management aws kubernetes environment.

# Usage

- Download this repository
- Copy *src* and *templates* folder to master template
- Add content of *.ps1.add* files to correspondent files from master template
- Add content of *config/config.k8s.json.add* to json config file from master template and set the required values

# Config parameters

Config variables description

| Variable | Default value | Description |
|----|----|---|
| aws_access_id | XXX | AWS id for access resources |
| aws_access_key | XXX | AWS key for access resources |
| aws_region | us-east-1 | AWS region where resources will be created |
| env_name | pip-templates-stage | Name of environment |
| vpc | vpc-bb755cc1 | Amazon Virtual Private Cloud name where resources will be created |
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
