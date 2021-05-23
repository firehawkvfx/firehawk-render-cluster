include {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

dependency "terraform-aws-user-data-rendernode" {
  config_path = "../terraform-aws-user-data-rendernode"
  mock_outputs = {
    user_data_base64 = "fake-user-data"
  }
}

dependency "terraform-aws-deadline-db" {
  config_path = "../terraform-aws-deadline-db"
  mock_outputs = {
    id = "fake-instance-id"
  }
}

inputs = merge(
  local.common_vars.inputs,
  {
    deadline_db_instance_id = dependency.terraform-aws-deadline-db.outputs.id
    user_data               = dependency.terraform-aws-user-data-rendernode.outputs.user_data_base64
  }
)

dependencies {
  paths = [ # not strictly dependencies, but if they fail, there is no point in continuing to deploy a vpc or anything else.
    "../terraform-aws-deadline-db",
    "../terraform-aws-sg-rendernode/module",
    "../../../firehawk-main/modules/terraform-aws-iam-profile-rendernode"
  ]
}

# skip = true
