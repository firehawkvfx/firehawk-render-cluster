# The user data for initialising render nodes.  This may be used in spot fleets or on demand instance types. base 64 encoding is preffered for output.

locals {
  resourcetier           = var.common_tags["resourcetier"]
  client_cert_file_path  = "/opt/Thinkbox/certs/Deadline10RemoteClient.pfx"
  client_cert_vault_path = "${local.resourcetier}/deadline/client_cert_files${local.client_cert_file_path}"
}

data "aws_ssm_parameter" "onsite_nfs_export" {
  name = "/firehawk/resourcetier/${var.resourcetier}/onsite_nfs_export"
}
data "aws_ssm_parameter" "onsite_nfs_mount_target" {
  name = "/firehawk/resourcetier/${var.resourcetier}/onsite_nfs_mount_target"
}
data "aws_ssm_parameter" "prod_mount_target" {
  name = "/firehawk/resourcetier/${var.resourcetier}/prod_mount_target"
}

data "template_file" "user_data_auth_client" {
  template = format("%s%s",
    file("${path.module}/user-data-iam-auth-ssh-host-consul.sh"),
    file("${path.module}/user-data-install-deadline-worker-cert.sh")
  )
  vars = {
    onsite_storage          = data.aws_ssm_parameter.onsite_storage.value
    onsite_nfs_export       = data.aws_ssm_parameter.onsite_nfs_export.value       # eg "192.168.92.11:/prod3"
    onsite_nfs_mount_target = data.aws_ssm_parameter.onsite_nfs_mount_target.value # eg "/onsite_prod"
    prod_mount_target       = data.aws_ssm_parameter.prod_mount_target.value       # eg "/prod"

    consul_cluster_tag_key   = var.consul_cluster_tag_key
    consul_cluster_tag_value = var.consul_cluster_name
    aws_internal_domain      = var.aws_internal_domain
    aws_external_domain      = "" # External domain is not used for internal hosts.
    example_role_name        = "rendernode-vault-role"

    deadlineuser_name                = "deadlineuser"
    deadline_version                 = var.deadline_version
    installers_bucket                = "software.${var.bucket_extension}"
    resourcetier                     = local.resourcetier
    deadline_installer_script_repo   = "https://github.com/firehawkvfx/packer-firehawk-amis.git"
    deadline_installer_script_branch = "deadline-immutable" # TODO This must become immutable - version it

    client_cert_file_path  = local.client_cert_file_path
    client_cert_vault_path = local.client_cert_vault_path

    houdini_license_server_address = var.houdini_license_server_address
    houdini_major_version          = "18.5" # TODO: this should be aquired from an AMI tag
  }
}
