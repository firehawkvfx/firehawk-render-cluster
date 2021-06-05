include {
  path = find_in_parent_folders()
}

locals {
  common_vars                  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  remote_cloud_private_ip_cidr = get_env("TF_VAR_remote_cloud_private_ip_cidr", "")
  onsite_private_subnet_cidr   = get_env("TF_VAR_onsite_private_subnet_cidr", "")
  vpn_cidr                     = get_env("TF_VAR_vpn_cidr", "")
  onsite_public_ip             = get_env("TF_VAR_onsite_public_ip", "")
  remote_cloud_public_ip_cidr  = get_env("TF_VAR_remote_cloud_public_ip_cidr", "")
}

dependency "data" {
  config_path = "../data"
  mock_outputs = {
    rendervpc_cidr = "fake-cidr1"
    private_subnet_cidr_blocks = "['fake-cidr33']"
    private_subnet_ids = "['fake-subnet-id']"
    public_subnet_cidr_blocks = "['fake-cidr33']"
    public_subnet_ids = "['fake-subnet-id']"
    cloud_s3_gateway = "false"
    aws_s3_bucket_arn = "fake-arn"
  }
}

dependencies {
  paths = [
    "../data"
  ]
}

inputs = merge(
  local.common_vars.inputs,
  {
    cloud_s3_gateway_enabled = ( dependency.data.outputs.cloud_s3_gateway == "true" ) ? true : false
    # 
    vpc_id = dependency.data.outputs.vpc_id
    subnet_ids = length( dependency.data.outputs.public_subnet_ids ) > 0 ? [ dependency.data.outputs.public_subnet_ids[0] ] : []
    permitted_cidr_list_private = concat( dependency.data.outputs.public_subnet_cidr_blocks,  [local.remote_cloud_private_ip_cidr, local.onsite_private_subnet_cidr, local.vpn_cidr] )
    deployment_cidr = dependency.data.outputs.rendervpc_cidr # TODO replace with a more specific list
    gateway_name = "cloud_s3_file_gateway"
    key_name = get_env("TF_VAR_aws_key_name", "")
    aws_s3_bucket_arn = dependency.data.outputs.aws_s3_bucket_arn
  }
)

# skip = true