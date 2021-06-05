include {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

dependency "data" {
  config_path = "../data"
  mock_outputs = {
    fsx_storage = "[]"
    fsx_private_ip = "fake-fsx-private-ip"
    fsx_mount_name = "fake-mount-name"
    fsx_dns_name = "fake-dns-name"
  }
}

inputs = merge(
  local.common_vars.inputs,
  {
    fsx_enabled = length( dependency.data.outputs.fsx_storage ) > 0 ? true : false
    fsx_private_ip = length( dependency.data.outputs.fsx_storage ) > 0 ? dependency.data.outputs.fsx_private_ip : null
    fsx_mount_name = length( dependency.data.outputs.fsx_storage ) > 0 ? dependency.data.outputs.fsx_mount_name : null
    fsx_dns_name = length( dependency.data.outputs.fsx_storage ) > 0 ? dependency.data.outputs.fsx_dns_name : null
  }
)

dependencies {
  paths = [
    "../data",
    ]
}

# skip = true