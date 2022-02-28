# This is a module example of how to use data resources as variable inputs to other modules.
# See an example here https://github.com/gruntwork-io/terragrunt/issues/254

provider "aws" {}

data "aws_ssm_parameter" "cloud_fsx_storage" {
  name = "/firehawk/resourcetier/${var.resourcetier}/cloud_fsx_storage"
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
data "aws_vpc" "rendervpc" {
  count = length(data.terraform_remote_state.rendervpc.outputs.vpc_id) > 0 ? 1 : 0
  default = false
  id = data.terraform_remote_state.rendervpc.outputs.vpc_id
  # tags    = var.common_tags_rendervpc
}
data "aws_subnet_ids" "private" {
  count = length(data.aws_vpc.rendervpc) > 0 ? 1 : 0
  vpc_id = data.aws_vpc.rendervpc[0].id
  tags   = tomap({ "area" : "private" })
}
data "aws_subnet" "private" {
  for_each = length(data.aws_subnet_ids.private) > 0 ? data.aws_subnet_ids.private[0].ids : []
  id       = each.value
}
output "vpc_id" {
  value = data.aws_vpc.rendervpc[0].id
}
output "rendervpc_cidr" {
  value = data.aws_vpc.rendervpc[0].cidr_block
}
output "private_subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.private : s.cidr_block]
}
output "private_subnet_ids" {
  value = [for s in data.aws_subnet.private : s.id]
}
output "cloud_fsx_storage" {
  value = data.aws_ssm_parameter.cloud_fsx_storage.value == "true" ? true : false
}