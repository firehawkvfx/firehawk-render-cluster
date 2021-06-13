variable "bucket_extension_vault" {
    description = "The bucket extension where the terraform remote state resides"
    type = string
}

variable "common_tags" {
  description = "Common tags for all resources in a deployment run."
  type        = map(string)
}