variable "resourcetier" {
  description = "The resource tier uniquely defining the deployment area.  eg: dev/green/blue/main"
  type        = string
}
variable "sqs_remote_in_deadline_cert_url" {
  description = "The SQS queue URL for a remote client to observe messages to establish connection with the VPN Server."
  type        = string
}
variable "host1" {
  description = "The user@publichost string to connect to the bastion host to aquire vpn credentials from Vault."
  type        = string
}
variable "host2" {
  description = "The user@privatehost string to connect to the vault client to aquire vpn credentials from Vault."
  type        = string
}
variable "instance_id" {
  description = "The Instance ID that will retrigger sending this data"
  type = string
  default = ""
}
variable "token_use_limit" {
  description = "The token use limit by default is enough for 10 hosts (10x4=40) to aquire a deadline certificate within 15 mins."
  type = string
  default = "40"
}