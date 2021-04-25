include {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

inputs = local.common_vars.inputs

# dependencies {
#   paths = [ # not strictly dependencies, but if they fail, there is no point in continuing to deploy a vpc or anything else.
#     "../terraform-aws-deadline-db",
#     "../terraform-aws-sg-rendernode/module",
#     "../../../firehawk-main/modules/terraform-aws-iam-profile-rendernode"
#     ]
# }

skip = true