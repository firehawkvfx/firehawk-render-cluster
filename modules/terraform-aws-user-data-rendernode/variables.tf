variable "consul_cluster_name" {
  description = "What to name the Consul server cluster and all of its associated resources"
  type        = string
}
variable "consul_cluster_tag_key" {
  description = "The tag the Consul EC2 Instances will look for to automatically discover each other and form a cluster."
  type        = string
}
variable "aws_internal_domain" {
  description = "The domain used to resolve internal FQDN hostnames."
  type        = string
}
variable "deadline_version" {
  description = "The deadline version to install"
  type        = string
}
variable "common_tags" {
  description = "A map of common tags to assign to the resources created by this module"
  type        = map(string)
  default     = {}
}
variable "bucket_extension" {
  description = "The bucket extension where the software installers reside"
  type        = string
}
variable "houdini_license_server_address" {
  description = "The IP or host name of your Houdini license server (IP Address is recommended to simplify usage across sites instead of DNS)."
  type        = string
}