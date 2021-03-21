# common variables to the project

locals { # inputs can't reference themselves, so we use locals first
    base_vpcname="rendervpc"
    projectname="firehawk-render-cluster" # A tag to recognise resources created in this project
    resourcetier=get_env("TF_VAR_resourcetier", "")
    vpcname="${local.resourcetier}${local.base_vpcname}"
    vpcname_vault="${local.resourcetier}vaultvpc"
    common_tags={
        "environment": get_env("TF_VAR_environment", ""),
        "resourcetier": get_env("TF_VAR_resourcetier", ""),
        "conflictkey": get_env("TF_VAR_conflictkey", ""),
        "pipelineid": get_env("TF_VAR_pipelineid", ""),
        "accountid": get_env("TF_VAR_account_id", ""),
        "owner": get_env("TF_VAR_owner", ""),
        "region": get_env("AWS_DEFAULT_REGION", ""),
        "vpcname": local.vpcname,
        "projectname": local.projectname,
        "terraform": local.resourcetier,
    }
}

inputs = { 
  base_vpcname = local.base_vpcname
  projectname = local.projectname
  resourcetier = local.resourcetier
  vpcname = local.vpcname
  vpcname_vault = local.vpcname_vault
  common_tags = local.common_tags
}