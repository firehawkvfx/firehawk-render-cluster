# This module will configure Deadline's Spot event plugin to scale render nodes based on the queue for deadline groups

resource "null_resource" "provision_deadline_spot" {
  count      = (var.aws_nodes_enabled && var.provision_deadline_spot_plugin) ? 1 : 0
  depends_on = [null_resource.dependency_deadline_spot, module.node.ami_id, module.firehawk_init.local-provisioning-complete]

  triggers = {
    ami_id                  = module.node.ami_id
    config_template_sha1    = sha1(file( fileexists(local.override_config_template_file_path) ? local.override_config_template_file_path : local.config_template_file_path))
    deadline_spot_sha1      = sha1(file("/deployuser/ansible/ansible_collections/firehawkvfx/deadline/deadline_spot.yaml"))
    deadline_spot_role_sha1 = sha1(file("/deployuser/ansible/ansible_collections/firehawkvfx/deadline/roles/deadline_spot/tasks/main.yml"))
    deadline_roles_tf_sha1  = sha1(file("/deployuser/modules/deadline/main.tf"))
    spot_access_key_id      = module.deadline.spot_access_key_id
    spot_secret             = module.deadline.spot_secret
    volume_size             = var.node_centos_volume_size
    volume_type             = var.node_centos_volume_type
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
      export SHOWCOMMANDS=true; set -x
      cd /deployuser
      echo ${module.deadline.spot_access_key_id}
      echo ${module.deadline.spot_secret}
      ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook -i "$TF_VAR_inventory" ansible/ansible_collections/firehawkvfx/deadline/deadline_spot.yaml -v --extra-vars 'volume_type=${var.node_centos_volume_type} volume_size=${var.node_centos_volume_size} ami_id=${module.node.ami_id} snapshot_id=${module.node.snapshot_id} subnet_id=${module.vpc.private_subnets[0]} spot_instance_profile_arn="${module.deadline.spot_instance_profile_arn}" security_group_id=${module.node.security_group_id} spot_access_key_id=${module.deadline.spot_access_key_id} spot_secret=${module.deadline.spot_secret} account_id=${lookup(local.common_tags, "accountid", "0")}'
EOT
  }
}