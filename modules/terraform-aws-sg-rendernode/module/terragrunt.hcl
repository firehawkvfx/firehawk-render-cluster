include {
  path = find_in_parent_folders()
}

locals {
  common_vars                  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  remote_cloud_private_ip_cidr = get_env("TF_VAR_remote_cloud_private_ip_cidr", "")
  onsite_private_subnet_cidr   = get_env("TF_VAR_onsite_private_subnet_cidr", "")
  vpn_cidr                     = get_env("TF_VAR_vpn_cidr", "")
  onsite_public_ip             = get_env("TF_VAR_onsite_public_ip", "")
  remote_cloud_public_ip_cidr  = get_env("TF_VAR_remote_cloud_public_ip_cidr", "")
}

dependency "data" {
  config_path = "../data"
}

dependencies {
  paths = [
    "../data",
    "../vpc"
  ]
}

inputs = merge(
  local.common_vars.inputs,
  {
    security_group_ids          = [dependency.data.outputs.bastion_security_group, dependency.data.outputs.vpn_security_group]
    permitted_cidr_list_private = [local.remote_cloud_private_ip_cidr, local.onsite_private_subnet_cidr, local.vpn_cidr]
    permitted_cidr_list         = ["${local.onsite_public_ip}/32", local.remote_cloud_public_ip_cidr, local.remote_cloud_private_ip_cidr, local.onsite_private_subnet_cidr, local.vpn_cidr, dependency.data.outputs.rendervpc_cidr, dependency.data.outputs.vaultvpc_cidr]
  }
)

# skip = true