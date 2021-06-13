include {
  path = find_in_parent_folders()
}

terraform {
  # source = "github.com/firehawkvfx/firehawk-main.git//modules/terraform-aws-vpn?ref=v0.0.22"
  source = "${get_env("TF_VAR_firehawk_path", "")}/modules/terraform-aws-vpn"
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

dependency "data" {
  config_path = "../data"
  mock_outputs = {
    remote_in_vpn_url = null
    bastion_public_dns = "fakepublicdns"
    vault_client_private_dns = "fakeprivatedns"
    vpn_security_group = null
  }
}

dependencies {
  paths = ["../data"]
}

inputs = merge(
  local.common_vars.inputs,
  {
    "security_group_ids" : [ dependency.data.outputs.vpn_security_group ]
    "sqs_remote_in_vpn" : dependency.data.outputs.remote_in_vpn_url
    "host1" : "centos@${dependency.data.outputs.bastion_public_dns}"
    "host2" : "centos@${dependency.data.outputs.vault_client_private_dns}"
    
  }
)