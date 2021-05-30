output "fsx_private_ip" {
  value = data.terraform_remote_state.fsx.outputs.fsx_private_ip
}