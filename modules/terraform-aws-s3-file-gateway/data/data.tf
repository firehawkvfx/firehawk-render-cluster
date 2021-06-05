# This is a module example of how to use data resources as variable inputs to other modules.
# See an example here https://github.com/gruntwork-io/terragrunt/issues/254

provider "aws" {}

# data "aws_ssm_parameter" "cloud_s3_gateway" {
#   name = "/firehawk/resourcetier/${var.resourcetier}/cloud_s3_gateway"
# }

data "aws_s3_bucket" "rendering_bucket" {
  bucket        = var.s3_bucket_name
}

data "aws_region" "current" {}

data "aws_vpc" "rendervpc" {
  default = false
  tags    = var.common_tags_rendervpc
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.rendervpc.id
  tags   = tomap({ "area" : "private" })
}
data "aws_subnet" "private" {
  for_each = data.aws_subnet_ids.private.ids
  id       = each.value
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.rendervpc.id
  tags   = tomap({ "area" : "public" })
}
data "aws_subnet" "public" {
  for_each = data.aws_subnet_ids.public.ids
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
  value = data.aws_vpc.rendervpc.id
}
output "rendervpc_cidr" {
  value = data.aws_vpc.rendervpc.cidr_block
}
output "cloud_s3_gateway" {
  value = true # data.aws_ssm_parameter.cloud_s3_gateway.value
}
output "aws_s3_bucket_arn" {
  value = data.aws_s3_bucket.rendering_bucket.arn
}