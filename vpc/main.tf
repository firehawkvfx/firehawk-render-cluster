provider "null" {
  version = "~> 3.0"
}

provider "aws" {
  # in a dev environment these version locks below can be disabled.  in production, they should be locked based on the suggested versions from terraform init.
  version = "~> 3.15.0"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_canonical_user_id" "current" {}

locals {
  common_tags = {
    environment  = var.environment
    resourcetier = var.resourcetier
    conflictkey  = var.conflictkey
    # The conflict key defines a name space where duplicate resources in different deployments sharing this name are prevented from occuring.  This is used to prevent a new deployment overwriting and existing resource unless it is destroyed first.
    # examples might be blue, green, dev1, dev2, dev3...dev100.  This allows us to lock deployments on some resources.
    pipelineid = var.pipelineid
    owner      = data.aws_canonical_user_id.current.display_name
    accountid  = data.aws_caller_identity.current.account_id
    region     = data.aws_region.current.name
    vpc = "${var.resourcetier}_render_vpc"
    terraform  = "true"
  }
}

module "vpc" {
  source                       = "./modules/terraform-aws-vpc"
  vpc_name                     = "${var.resourcetier}_vault_vpc"
  vpc_cidr                     = module.rendervpc_all_subnet_cidrs.base_cidr_block
  public_subnets               = module.rendervpc_all_public_subnet_cidrs.networks[*].cidr_block
  private_subnets              = module.rendervpc_all_private_subnet_cidrs.networks[*].cidr_block
  sleep                        = var.sleep
  deployer_ip_cidr             = var.deployer_ip_cidr
  remote_cloud_public_ip_cidr  = var.remote_cloud_public_ip_cidr
  remote_cloud_private_ip_cidr = var.remote_cloud_private_ip_cidr
  common_tags                  = local.common_tags
}

module "consul_client_security_group" {
  source              = "./modules/consul-client-security-group"
  common_tags         = local.common_tags
  create_vpc          = true
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = module.resourcetier_all_vpc_cidrs.base_cidr_block
  permitted_cidr_list = [var.deployer_ip_cidr, var.remote_cloud_private_ip_cidr, var.remote_cloud_public_ip_cidr]
}

module "resourcetier_all_vpc_cidrs" { # all vpcs contained in the combined_vpcs_cidr (current resource tier dev or green or blue or main)
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.combined_vpcs_cidr
  networks = [
    {
      name     = "vaultvpc"
      new_bits = 8
    },
    {
      name     = "rendervpc"
      new_bits = 1
    }
  ]
}

module "rendervpc_all_subnet_cidrs" { # all private/public subnet ranges 
  source = "hashicorp/subnets/cidr"

  base_cidr_block = module.resourcetier_all_vpc_cidrs.network_cidr_blocks["rendervpc"]
  networks = [
    {
      name     = "privatesubnets"
      new_bits = 1
    },
    {
      name     = "publicsubnets"
      new_bits = 1
    }
  ]
}

module "rendervpc_all_private_subnet_cidrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = module.rendervpc_all_subnet_cidrs.network_cidr_blocks["privatesubnets"]
  networks = [
    for i in range(var.vault_vpc_subnet_count) : { name = format("privatesubnet%s", i), new_bits = 2 }
  ]
}

module "rendervpc_all_public_subnet_cidrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = module.rendervpc_all_subnet_cidrs.network_cidr_blocks["publicsubnets"]
  networks = [
    for i in range(var.vault_vpc_subnet_count) : { name = format("publicsubnet%s", i), new_bits = 2 }
  ]
}