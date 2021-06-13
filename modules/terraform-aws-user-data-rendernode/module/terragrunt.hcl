include {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

dependency "data" {
  config_path = "../data"
  mock_outputs = {
    fsx_enabled = false
    fsx_storage = []
    fsx_private_ip = "fake-fsx-private-ip"
    fsx_mount_name = "fake-mount-name"
    fsx_dns_name = "fake-dns-name"
    nfs_file_gateway = false
    nfs_file_share_path = "/fake-path"
  }
}

# output "nfs_file_gateway" {
#   value = data.terraform_remote_state.file_gateway.outputs.nfs_file_gateway
# }
# output "nfs_private_ip" {
#   value = length( data.terraform_remote_state.file_gateway.outputs.nfs_file_gateway ) ? data.terraform_remote_state.file_gateway.outputs.nfs_private_ip : null
# }
# output "nfs_file_share_path" {
#   value = length( data.terraform_remote_state.file_gateway.outputs.nfs_file_gateway ) ? data.terraform_remote_state.file_gateway.outputs.nfs_file_share_path : null
# }

inputs = merge(
  local.common_vars.inputs,
  {
    fsx_enabled = length( dependency.data.outputs.fsx_storage ) > 0 ? true : false
    fsx_private_ip = length( dependency.data.outputs.fsx_storage ) > 0 ? dependency.data.outputs.fsx_private_ip : null
    fsx_mount_name = length( dependency.data.outputs.fsx_storage ) > 0 ? dependency.data.outputs.fsx_mount_name : null
    fsx_dns_name = length( dependency.data.outputs.fsx_storage ) > 0 ? dependency.data.outputs.fsx_dns_name : null
    nfs_cloud_file_gateway_enabled = length( dependency.data.outputs.nfs_file_gateway ) > 0 ? true : false
    nfs_cloud_file_gateway_private_ip = length( dependency.data.outputs.nfs_file_gateway ) > 0 ? dependency.data.outputs.nfs_private_ip : null
    nfs_cloud_file_gateway_share_path = length( dependency.data.outputs.nfs_file_gateway ) > 0 ? dependency.data.outputs.nfs_file_share_path : null
  }
)

dependencies {
  paths = [
    "../data",
    ]
}

# skip = true