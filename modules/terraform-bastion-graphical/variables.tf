variable "name" {
  default = "bastion_graphical"
  type = string
}

variable "bastion_graphical_ami_id" {
  description = "The prebuilt AMI for the bastion host. This should be a private ami you have built with packer."
  type = string
  default = null
}

variable "bastion_ip" {} # the address to use for the bastion to ssh into this host.  although it is also technically a bastion, it should be provisioned with ssh via a the single accesss point for the network

variable "create_vpc" {}

variable "create_vpn" {
  default = false
}

variable "vpc_id" {
}

variable "vpc_cidr" {
}

# deployer_ip_cidr is the ip address of the remote host / user intending to connect over vpn. eg '197.125.62.53/32'
#example "125.254.24.255/32"
variable "vpn_cidr" {
}

variable "deployer_ip_cidr" {
}

variable "remote_ip_graphical_cidr" {
}

variable "public_subnets_cidr_blocks" {
}

variable "route_public_domain_name" {}

variable "aws_private_key_path" {
}

# examples ["subnet-0a7554f56af4d6d0a", "subnet-0257c7f8b1d68b6e4"]
variable "public_subnet_ids" {
  default = []
}

variable "aws_key_name" {
}

#contents of the my_key.pem file to connect to the instance.
variable "private_key" {
}

variable "instance_type" {
  # default = "g3s.xlarge"
  default = "m4.large"
}

variable "user" {
  default = "centos"
}

variable "sleep" {
  default = false
}

variable "skip_update" {
  default = false
}

variable "consul_cluster_name" {
  description = "What to name the Consul server cluster and all of its associated resources"
  type        = string
  default     = "consul-example"
}

variable "consul_cluster_tag_key" {
  description = "The tag the Consul EC2 Instances will look for to automatically discover each other and form a cluster."
  type        = string
  default     = "consul-servers"
}
