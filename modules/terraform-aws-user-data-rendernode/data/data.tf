# This is a module example of how to use data resources as variable inputs to other modules.
# See an example here https://github.com/gruntwork-io/terragrunt/issues/254

provider "aws" {}

data "aws_region" "current" {}

data "terraform_remote_state" "fsx" { # read the arn with data.terraform_remote_state.packer_profile.outputs.instance_role_arn, or read the profile name with data.terraform_remote_state.packer_profile.outputs.instance_profile_name
  backend = "s3"
  config = {
    bucket = "state.terraform.${var.bucket_extension}"
    key    = "firehawk-render-cluster/modules/terraform-aws-fsx/module/terraform.tfstate"
    region = data.aws_region.current.name
  }
}

output "fsx_private_ip" {
  value = data.terraform_remote_state.fsx.outputs.fsx_private_ip
}