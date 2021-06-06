variable "cloud_s3_gateway_enabled" {
  description = "Bool enabling FSX storage"
  type        = bool
  default     = true
}
variable "ebs_cache_volume_size" {
  description = "The size, in GB, for the cache volume associated with this file gateway"
  default     = 150
}
variable "instance_type" {
  description = "The type of EC2 instance to launch.  Consult the AWS Storage Gateway documentation for supported instance types"
  default     = "m4.xlarge"
}
variable "instance_name" {
  description = "The name for the instance"
  type        = string
  default     = "filegateway"
}
variable "client_access_list" {
  type        = list(string)
  description = "The list of client IPs or CIDR blocks that can access the gateway"
  default     = ["0.0.0.0/0"]
}
variable "aws_s3_bucket_arn" {
  description = "The ARN of the S3 bucket to use for the backend"
  type        = string
  default     = null
}
# variable "bucket_name" {
#   description = "The name to give your S3 bucket"
# }
variable "key_name" {
  description = "The AWS key to be used during the creation of this instance"
}
variable "gateway_name" {
  description = "The friendly name to assign to the storage gateway"
}
variable "gateway_time_zone" {
  description = "The time zone the gateway should use.  Entered in the format GMT-6:00"
  type        = string
  default     = "GMT"
}
variable "subnet_ids" {
  description = "The list of subnet ID's for FSX endpoints."
  type        = list(string)
  default     = []
}
variable "common_tags" {
  description = "Common tags for all resources in a deployment run."
  type        = map(string)
}
variable "vpc_id" {
  description = "The ID of the VPC to deploy into. Leave an empty string to use the Default VPC in this region."
  type        = string
  default     = null
}
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
variable "deployment_cidr" {
  description = "The CIDR block for the IP range from which your hosts will deploy and configure the gateway"
}
variable "application" {
  description = "The application for the role"
  default     = "rendering"
}
variable "role" {
  description = "The role name"
  default     = "filegateway"
}
variable "resourcetier" {
  description = "The resource tier speicifies a unique name for a resource based on the environment.  eg:  dev, green, blue, main."
  type        = string
}
variable "owner_id" {
  description = "The default owner ID for the NFS share"
  type = string
  default = null
}
variable "group_id" {
  description = "The default group ID for the NFS share"
  type = string
  default = null
}