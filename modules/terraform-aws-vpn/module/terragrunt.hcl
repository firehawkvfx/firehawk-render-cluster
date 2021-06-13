include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/firehawkvfx/terraform-aws-vpn.git//?ref=v0.0.6"
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

dependency "data" {
  config_path = "../data"
  mock_outputs = {
    remote_in_vpn_arn = "fake_arn"
  }
}

dependencies {
  paths = ["../data"]
}

inputs = merge(
  local.common_vars.inputs,
  {
    "sqs_remote_in_vpn" : dependency.data.outputs.sqs_remote_in_vpn
    "host1" : "centos@${dependency.data.outputs.bastion_public_dns}"
    "host2" : "centos@${dependency.data.outputs.vault_client_private_dns}"
  }
)