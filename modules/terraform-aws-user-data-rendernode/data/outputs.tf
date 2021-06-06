output "fsx_storage" {
  value = data.terraform_remote_state.fsx.outputs.fsx_storage
}
output "fsx_private_ip" {
  value = length( data.terraform_remote_state.fsx.outputs.fsx_storage ) > 0 ? data.terraform_remote_state.fsx.outputs.fsx_private_ip : null
}
output "fsx_dns_name" {
  value = length( data.terraform_remote_state.fsx.outputs.fsx_storage ) > 0 ? data.terraform_remote_state.fsx.outputs.fsx_dns_name : null
}
output "fsx_mount_name" {
  value = length( data.terraform_remote_state.fsx.outputs.fsx_storage ) > 0 ? data.terraform_remote_state.fsx.outputs.fsx_mount_name : null
}

output "nfs_file_gateway" {
  value = data.terraform_remote_state.file_gateway.outputs.nfs_file_gateway
}
output "nfs_private_ip" {
  value = length( data.terraform_remote_state.file_gateway.outputs.nfs_file_gateway ) > 0 ? data.terraform_remote_state.file_gateway.outputs.nfs_private_ip : null
}
output "nfs_file_share_path" {
  value = length( data.terraform_remote_state.file_gateway.outputs.nfs_file_gateway ) > 0 ? data.terraform_remote_state.file_gateway.outputs.nfs_file_share_path : null
}