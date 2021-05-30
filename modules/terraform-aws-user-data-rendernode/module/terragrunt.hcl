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
  }
}

inputs = merge(
  local.common_vars.inputs,
  {
    fsx_private_ip = dependency.data.outputs.fsx_private_ip
  }
)

dependencies {
  paths = [
    "../data",
    ]
}

# skip = true