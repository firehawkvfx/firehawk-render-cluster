include {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

inputs = local.common_vars.inputs

dependencies {
  paths = [
    "../terraform-aws-render-vpc",
    "../terraform-aws-render-vpc-vault-vpc-peering",
    "../../../firehawk-main/modules/terraform-aws-sg-vpn",
    "../../../firehawk-main/modules/vault",
    "../../../firehawk-main/modules/terraform-aws-iam-profile-openvpn"
    ]
}

terraform {
  source = "github.com/firehawkvfx/firehawk-main.git//modules/terraform-aws-vpn?ref=rendervpc-vpn"
}
