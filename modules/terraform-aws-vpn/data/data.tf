data "aws_region" "current" {}
data "terraform_remote_state" "terraform_aws_sqs_vpn" { # read the arn with data.terraform_remote_state.packer_profile.outputs.instance_role_arn, or read the profile name with data.terraform_remote_state.packer_profile.outputs.instance_profile_name
  backend = "s3"
  config = {
    bucket = "state.terraform.${var.bucket_extension_vault}"
    key    = "init/modules/terraform-aws-sqs-vpn/terraform.tfstate"
    region = data.aws_region.current.name
  }
}
data "terraform_remote_state" "terraform_aws_vault_client" { # read the arn with data.terraform_remote_state.packer_profile.outputs.instance_role_arn, or read the profile name with data.terraform_remote_state.packer_profile.outputs.instance_profile_name
  backend = "s3"
  config = {
    bucket = "state.terraform.${var.bucket_extension_vault}"
    key    = "firehawk-main/modules/terraform-aws-vault-client/terraform.tfstate"
    region = data.aws_region.current.name
  }
}
data "terraform_remote_state" "terraform_aws_bastion" { # read the arn with data.terraform_remote_state.packer_profile.outputs.instance_role_arn, or read the profile name with data.terraform_remote_state.packer_profile.outputs.instance_profile_name
  backend = "s3"
  config = {
    bucket = "state.terraform.${var.bucket_extension_vault}"
    key    = "firehawk-main/modules/terraform-aws-bastion/terraform.tfstate"
    region = data.aws_region.current.name
  }
}
# data "aws_security_group" "vpn_security_group" { # Aquire the security group ID for external bastion hosts, these will require SSH access to this internal host.  Since multiple deployments may exist, the pipelineid allows us to distinguish between unique deployments.
#   tags = merge( local.common_tags, tomap( {
#     "role": "vpn",
#     "route": "public"
#   } ) )
#   name = "${lookup(local.common_tags, "vpcname", "default")}_openvpn_ec2_pipeid${lookup(local.common_tags, "pipelineid", "0")}" # name is important to use since tags cannot be controlled - names must be unique, so if it was already taken there would be an error.
#   vpc_id = data.aws_vpc.primary.id
# }