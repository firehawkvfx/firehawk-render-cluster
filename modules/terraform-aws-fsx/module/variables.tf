variable "fsx_storage" {}

variable "fsx_storage_capacity" {}

variable "fsx_bucket_prefix" {}
variable "bucket_extension" {}

variable "subnet_ids" {
  default = []
}

variable "common_tags" {}

variable "vpc_id" {}

variable "vpn_cidr" {}

variable "private_subnets_cidr_blocks" {
  # default = []
}

variable "vpc_cidr" {}

variable "public_subnets_cidr_blocks" {
  # default = []
}

variable "onsite_private_subnet_cidr" {}

variable "deployer_ip_cidr" {}

variable "vpn_private_ip" {}

variable "sleep" {
  description = "Sleep if true may temporarily be used to destroy some resources to reduce idle costs."
  type        = bool
  default     = false
}

variable "permitted_cidr_list_private" {
  description = "The list of CIDR blocks to allow acces to FSX"
  type        = list(string)
  default     = []
}

variable "fsx_record_enabled" {
  description = "Whether to add a DNS record using Route 53"
  type = bool
  default = false
}

variable "remote_mounts_on_local" {}

variable "envtier" {}

variable "private_route53_zone_id" {}

variable "private_domain" {}
variable "fsx_hostname" {}