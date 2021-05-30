output "fsx_private_ip" {
  value = data.terraform_remote_state.fsx.outputs.fsx_private_ip
}
output "fsx_dns_name" {
  value = data.terraform_remote_state.fsx.outputs.fsx_dns_name
}
output "fsx_mount_name" {
  value = data.terraform_remote_state.fsx.outputs.fsx_mount_name
}