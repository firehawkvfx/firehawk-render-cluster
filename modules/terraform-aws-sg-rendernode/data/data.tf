# This is a module example of how to use data resources as variable inputs to other modules.
# See an example here https://github.com/gruntwork-io/terragrunt/issues/254

provider "aws" {
  version = "~> 3.15.0"
}
data "aws_region" "current" {}
data "terraform_remote_state" "bastion_security_group" { # read the arn with data.terraform_remote_state.packer_profile.outputs.instance_role_arn, or read the profile name with data.terraform_remote_state.packer_profile.outputs.instance_profile_name
  backend = "s3"
  config = {
    bucket = "state.terraform.${var.bucket_extension_vault}"
    key    = "firehawk-main/modules/terraform-aws-sg-bastion/terraform.tfstate"
    region = data.aws_region.current.name
  }
}
data "terraform_remote_state" "vpn_security_group" { # read the arn with data.terraform_remote_state.packer_profile.outputs.instance_role_arn, or read the profile name with data.terraform_remote_state.packer_profile.outputs.instance_profile_name
  backend = "s3"
  config = {
    bucket = "state.terraform.${var.bucket_extension}"
    key    = "firehawk-render-cluster/modules/terraform-aws-sg-vpn/terraform.tfstate"
    region = data.aws_region.current.name
  }
}
data "aws_vpc" "rendervpc" {
  default = false
  tags    = var.common_tags_rendervpc
}
data "aws_vpc" "vaultvpc" {
  default = false
  tags    = var.common_tags_vaultvpc
}
output "bastion_security_group" {
  value = data.terraform_remote_state.bastion_security_group.outputs.security_group_id
}
output "vpn_security_group" {
  value = data.terraform_remote_state.vpn_security_group.outputs.security_group_id
}
output "rendervpc_cidr" {
  value = data.aws_vpc.rendervpc.cidr_block
}
output "vaultvpc_cidr" {
  value = data.aws_vpc.vaultvpc.cidr_block
}