include {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

dependency "data" {
  config_path = "../data"
  mock_outputs = {
    fsx_private_ip = "fake-fsx-private-ip"
    fsx_mount_name = "fake-mount-name"
    fsx_dns_name = "fake-dns-name"
  }
}

inputs = merge(
  local.common_vars.inputs,
  {
    fsx_private_ip = dependency.data.outputs.fsx_private_ip
    fsx_mount_name = dependency.data.outputs.fsx_mount_name
    fsx_dns_name = dependency.data.outputs.fsx_dns_name
  }
)

dependencies {
  paths = [
    "../data",
    ]
}

# skip = true