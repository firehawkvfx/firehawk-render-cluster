provider "null" {
  version = "~> 3.0"
}

provider "aws" {
  #  if you haven't installed and configured the aws cli, you will need to provide your aws access key and secret key.
  # in a dev environment these version locks below can be disabled.  in production, they should be locked based on the suggested versions from terraform init.
  version = "~> 3.15.0"
}
data "aws_vpc" "primary" { # this vpc
  default = false
  tags    = local.common_tags
}
data "aws_vpc" "vaultvpc" { # vault vpc
  default = false
  tags = local.vaultvpc_tags
}
data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.primary.id
  tags = merge( local.common_tags, { "area" : "public" } )
}

data "aws_subnet" "public" {
  for_each = data.aws_subnet_ids.public.ids
  id       = each.value
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.primary.id
  tags = merge( local.common_tags, { "area" : "private" } )
}

data "aws_subnet" "private" {
  for_each = data.aws_subnet_ids.private.ids
  id       = each.value
}

data "aws_route_tables" "public" {
  vpc_id = data.aws_vpc.primary.id
  tags = merge( local.common_tags, { "area" : "public" } )
}

data "aws_route_tables" "private" {
  vpc_id = data.aws_vpc.primary.id
  tags = merge( local.common_tags, { "area" : "public" } )
}

data "aws_security_group" "bastion" { # Aquire the security group ID for external bastion hosts, these will require SSH access to this internal host.  Since multiple deployments may exist, the pipelineid allows us to distinguish between unique deployments.
  tags = merge( local.common_tags, local.bastion_tags ) # Since we deploy vault alongside this account, pipelineid will probably not be an issue...  At some point we will need to create a dependency of the vault vpc output and what tags we should be using with multi account and CI.
  vpc_id = data.aws_vpc.vaultvpc.id
}

locals {
  vaultvpc_tags = {
    vpcname = var.vpcname_vault,
    projectname = "firehawk-main"
  }
  bastion_tags = {
    vpcname = var.vpcname_vault
    role    = "bastion"
    route   = "public"
  }
  common_tags = var.common_tags
  mount_path  = var.resourcetier
  vpc_id      = data.aws_vpc.primary.id
  vpc_cidr    = data.aws_vpc.primary.cidr_block

  vpn_cidr                   = var.vpn_cidr
  onsite_private_subnet_cidr = var.onsite_private_subnet_cidr

  private_subnet_ids         = tolist(data.aws_subnet_ids.private.ids)
  private_subnet_cidr_blocks = [for s in data.aws_subnet.private : s.cidr_block]
  onsite_public_ip           = var.onsite_public_ip
  private_route_table_ids    = data.aws_route_tables.private.ids
}
module "vault_client" {
  source              = "../../../firehawk-main/modules/terraform-aws-vault-client/modules/vault-client" # this should reference a tgged version of the git hub repo in production.
  name                = "${local.vpcname}_vaultclient_pipeid${lookup(local.common_tags, "pipelineid", "0")}"
  vault_client_ami_id = var.vault_client_ami_id

  consul_cluster_name    = var.consul_cluster_name
  consul_cluster_tag_key = var.consul_cluster_tag_key
  aws_internal_domain    = var.aws_internal_domain
  vpc_id                 = local.vpc_id
  vpc_cidr               = local.vpc_cidr

  private_subnet_ids  = local.private_subnet_ids
  permitted_cidr_list = ["${local.onsite_public_ip}/32", var.remote_cloud_public_ip_cidr, var.remote_cloud_private_ip_cidr, local.onsite_private_subnet_cidr, local.vpn_cidr]
  security_group_ids  = [data.aws_security_group.bastion.id]

  aws_key_name = var.aws_key_name
  common_tags = local.common_tags

  bucket_extension_vault = var.bucket_extension_vault
  resourcetier_vault = var.resourcetier_vault
  vpcname_vault = var.vpcname_vault
  vpcname = var.common_tags["vpcname"]
}