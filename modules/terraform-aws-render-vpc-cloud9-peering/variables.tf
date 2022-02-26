variable "sleep" {
  description = "Sleep will disable the nat gateway and shutdown instances to save cost during idle time."
  type        = bool
  default     = false
}
variable "vpc_id_main_provisioner" {
  description = "The VPC ID containing the cloud9 seed instance in your main account.  This will be used to establish VPC peering with vault."
  type        = string
}
variable "environment" {
  description = "The environment.  eg: dev/prod"
  type        = string
}
variable "resourcetier" {
  description = "The resource tier uniquely defining the deployment area.  eg: dev/green/blue/main"
  type        = string
}
variable "pipelineid" {
  description = "The pipelineid uniquely defining the deployment instance if using CI.  eg: dev/green/blue/main"
  type        = string
}
variable "conflictkey" {
  description = "The conflictkey is a unique name for each deployement usuallly consisting of the resourcetier and the pipeid."
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources in a deployment run."
  type        = map(string)
}

variable "common_tags_rendervpc" {
  description = "Common tags for resources in the render vpc / firehawk-render-cluster project."
  type        = map(string)
}

variable "common_tags_deployervpc" {
  description = "Common tags for resources in the deployer vpc / firehawk-render-cluster project."
  type        = map(string)
}