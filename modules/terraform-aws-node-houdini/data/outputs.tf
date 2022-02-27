output "user_data_base64" {
  value = try(data.terraform_remote_state.user_data.outputs.user_data_base64, null)
}
output "rendervpc_id" {
  value = try(data.aws_vpc.rendervpc.id, null)
}
output "vaultvpc_id" {
  value = try(data.aws_vpc.vaultvpc.id, null)
}