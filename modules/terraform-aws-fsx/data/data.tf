# This is a module example of how to use data resources as variable inputs to other modules.
# See an example here https://github.com/gruntwork-io/terragrunt/issues/254

provider "aws" {}

data "aws_ssm_parameter" "cloud_fsx_storage" {
  name = "/firehawk/resourcetier/${var.resourcetier}/cloud_fsx_storage"
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
output "vpc_id" {
  value = data.aws_vpc.rendervpc.id
}
output "rendervpc_cidr" {
  value = data.aws_vpc.rendervpc.cidr_block
}
output "private_subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.private : s.cidr_block]
}
output "private_subnet_ids" {
  value = [for s in data.aws_subnet.private : s.id]
}
output "cloud_fsx_storage" {
  value = data.aws_ssm_parameter.cloud_fsx_storage.value
}