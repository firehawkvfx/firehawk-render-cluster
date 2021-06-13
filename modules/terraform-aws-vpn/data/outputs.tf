output "remote_in_vpn_arn" {
  value = data.terraform_remote_state.terraform_aws_sqs_vpn.outputs.remote_in_vpn_arn
}
output "bastion_public_dns" {
  value = data.terraform_remote_state.terraform_aws_bastion.outputs.public_dns
}
output "vault_client_private_dns" {
  value = data.terraform_remote_state.terraform_aws_vault_client.outputs.consul_private_dns
}