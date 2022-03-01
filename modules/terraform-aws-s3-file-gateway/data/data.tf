# This is a module example of how to use data resources as variable inputs to other modules.
# See an example here https://github.com/gruntwork-io/terragrunt/issues/254

provider "aws" {}

data "aws_ssm_parameter" "cloud_s3_gateway" {
  name = "/firehawk/resourcetier/${var.resourcetier}/cloud_s3_gateway"
}
data "aws_ssm_parameter" "cloud_s3_gateway_mount_target" {
  name = "/firehawk/resourcetier/${var.resourcetier}/cloud_s3_gateway_mount_target"
}
data "aws_ssm_parameter" "cloud_s3_gateway_size" {
  name = "/firehawk/resourcetier/${var.resourcetier}/cloud_s3_gateway_size"
}

data "aws_s3_bucket" "rendering_bucket" {
  bucket        = var.s3_bucket_name
}

data "aws_region" "current" {}

data "terraform_remote_state" "rendervpc" {
  backend = "s3"
  config = {
    bucket = "state.terraform.${var.bucket_extension}"
    key    = "firehawk-render-cluster/modules/terraform-aws-render-vpc/terraform.tfstate"
    region = data.aws_region.current.name
  }
}
locals {
  rendervpc_id = length( try(data.terraform_remote_state.rendervpc.outputs.vpc_id, "" ) ) > 0 ? data.terraform_remote_state.rendervpc.outputs.vpc_id : ""
}

data "aws_vpc" "rendervpc" {
  count = length(local.rendervpc_id) > 0 ? 1 : 0
  default = false
  id = local.rendervpc_id
}

# data "aws_subnet_ids" "private" {
#   vpc_id = data.aws_vpc.rendervpc.id
#   tags   = tomap({ "area" : "private" })
# }
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = length(local.rendervpc_id) > 0 ? [local.rendervpc_id] : []
  }
  tags = {
    area = "private"
  }
}
data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

# data "aws_subnet_ids" "public" {
#   vpc_id = data.aws_vpc.rendervpc.id
#   tags   = tomap({ "area" : "public" })
# }
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = length(local.rendervpc_id) > 0 ? [local.rendervpc_id] : []
  }
  tags = {
    area = "public"
  }
}
data "aws_subnet" "public" {
  for_each = data.aws_subnets.public.ids
  id       = each.value
}

output "private_subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.private : s.cidr_block]
}
output "private_subnet_ids" {
  value = [for s in data.aws_subnet.private : s.id]
}

output "public_subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.public : s.cidr_block]
}
output "public_subnet_ids" {
  value = [for s in data.aws_subnet.public : s.id]
}
output "vpc_id" {
  value = local.rendervpc_id
}
output "rendervpc_cidr" {
  value = length(data.aws_vpc.rendervpc) > 0 ? data.aws_vpc.rendervpc[0].cidr_block : ""
}
output "cloud_s3_gateway" {
  value = data.aws_ssm_parameter.cloud_s3_gateway.value
}
output "cloud_s3_gateway_mount_target" {
  value = data.aws_ssm_parameter.cloud_s3_gateway_mount_target.value
}
output "cloud_s3_gateway_size" {
  value = data.aws_ssm_parameter.cloud_s3_gateway_size.value
}
output "aws_s3_bucket_arn" {
  value = data.aws_s3_bucket.rendering_bucket.arn
}