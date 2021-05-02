# The user data for initialising render nodes.  This may be used in spot fleets or on demand instance types. base 64 encoding is preffered for output.

locals {
  resourcetier           = var.common_tags["resourcetier"]
  client_cert_file_path  = "/opt/Thinkbox/certs/Deadline10RemoteClient.pfx"
  client_cert_vault_path = "${local.resourcetier}/deadline/client_cert_files${local.client_cert_file_path}"
}

data "template_file" "user_data_auth_client" {
  template = format("%s%s",
    file("${path.module}/user-data-iam-auth-ssh-host-consul.sh"),
    file("${path.module}/user-data-install-deadline-worker-cert.sh")
  )
  vars = {
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
  }
}