output "user_data_base64" {
  value = data.terraform_remote_state.user_data.outputs.user_data_base64
}