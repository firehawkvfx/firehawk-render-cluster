# This module will configure Deadline's Spot event plugin to scale render nodes based on the queue for deadline groups

data "aws_region" "current" {}
data "aws_ami" "rendernode" {
  most_recent = true
  # If we change the AWS Account in which test are run, update this value.
  owners = ["self"]
  filter {
    name   = "tag:ami_role"
    values = ["firehawk_centos7_rendernode_ami"]
  }
  # filter { # This should be used in production
  #   name   = "tag:commit_hash"
  #   values = [var.ami_commit_hash]
  # }
}
data "aws_vpc" "rendervpc" {
  default = false
  tags    = var.common_tags_rendervpc
}
data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.rendervpc.id
  tags   = map("area", "private")
}
data "terraform_remote_state" "rendernode_profile" { # read the arn with data.terraform_remote_state.packer_profile.outputs.instance_role_arn, or read the profile name with data.terraform_remote_state.packer_profile.outputs.instance_profile_name
  backend = "s3"
  config = {
    bucket = "state.terraform.${var.bucket_extension_vault}"
    key    = "firehawk-main/modules/terraform-aws-iam-profile-rendernode/terraform.tfstate"
    region = data.aws_region.current.name
  }
}
data "terraform_remote_state" "rendernode_security_group" { # read the arn with data.terraform_remote_state.packer_profile.outputs.instance_role_arn, or read the profile name with data.terraform_remote_state.packer_profile.outputs.instance_profile_name
  backend = "s3"
  config = {
    bucket = "state.terraform.${var.bucket_extension}"
    key    = "firehawk-render-cluster/modules/terraform-aws-sg-rendernode/module/terraform.tfstate"
    region = data.aws_region.current.name
  }
}
output "block_device_mappings" {
  value = data.aws_ami.rendernode.block_device_mappings
}

variable "ebs_empty_map" {
  type = map(string)
  default = {
    device_name = "/dev/sda1"
    snapshot_id = ""
  }
}
# We create a list with a dummy map as the 2nd / last element.
locals {
  # ebs_block_device_extended = concat(data.aws_ami.rendernode.block_device_mappings, list(list(var.ebs_empty_map)))
  # We select the first element in the list.  if the actual node exists, we will eventually get a valid value after the for loop below, otherwise it will return blank from the empty map, which is fine, since the ami id should never be referenced in this state.
  # ebs_block_device_selected = element(data.aws_ami.rendernode.block_device_mappings, 0)
  ebs_block_device_selected = data.aws_ami.rendernode.block_device_mappings
}

# This loop creates key's based on the device name, so the snapshot_id can be retrieved by the device name.
locals {
  ebs_block_device = {
    for bd in local.ebs_block_device_selected :
    bd.device_name => bd
  }
}

output "ebs_block_device" {
  value = local.ebs_block_device
}

output "snapshot_id" {
  value = local.ebs_block_device["/dev/sda1"].ebs.snapshot_id
}



locals {
  ami_id = data.aws_ami.rendernode.id
  # snapshot_id                        = data.aws_ami.rendernode.id.block_device_mappings["/dev/sda1"].snapshot_id
  snapshot_id                        = "unknown"
  private_subnet_ids                 = tolist(data.aws_subnet_ids.private.ids)
  instance_profile                   = data.terraform_remote_state.rendernode_profile.outputs.instance_profile_arn
  security_group_id                  = data.terraform_remote_state.rendernode_security_group.outputs.security_group_id
  config_template_file_path          = "${path.module}/ansible/collections/ansible_collections/firehawkvfx/deadline/roles/deadline_spot/files/config_template.json"
  override_config_template_file_path = "/home/ec2-user/config_template.json"
}
resource "null_resource" "provision_deadline_spot" {
  count      = 1
  triggers = {
    ami_id                  = local.ami_id
    config_template_sha1    = sha1(file(fileexists(local.override_config_template_file_path) ? local.override_config_template_file_path : local.config_template_file_path))
    deadline_spot_sha1      = sha1(file("${path.module}/ansible/collections/ansible_collections/firehawkvfx/deadline/deadline_spot.yaml"))
    deadline_spot_role_sha1 = sha1(file("${path.module}/ansible/collections/ansible_collections/firehawkvfx/deadline/roles/deadline_spot/tasks/main.yml"))
    deadline_roles_tf_sha1  = sha1(local.instance_profile)
    # spot_access_key_id      = module.deadline.spot_access_key_id
    # spot_secret             = module.deadline.spot_secret
    volume_size = var.node_centos_volume_size
    volume_type = var.node_centos_volume_type
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
export SHOWCOMMANDS=true; set -x
echo "Ensure SSH Certs are configured correctly with the current instance for the Ansible playbook to configure Deadline Spot Plugin"
cd ${path.module}
printf "\n...Waiting for consul deadlinedb service before attempting to configure.\n\n"
until consul catalog services | grep -m 1 "deadlinedb"; do sleep 1 ; done
set -x
ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook -vv -i "${path.module}/ansible/inventory/hosts" ansible/collections/ansible_collections/firehawkvfx/deadline/deadline_spot.yaml -v --extra-vars "config_generated_json=/home/ubuntu/config_generated.json \
  max_spot_capacity_engine=1 \
  max_spot_capacity_mantra=1 \
  volume_type=${var.node_centos_volume_type} \
  volume_size=${var.node_centos_volume_size} \
  ami_id=${local.ami_id} \
  snapshot_id=${local.snapshot_id} \
  subnet_id=${local.private_subnet_ids[0]} \
  spot_instance_profile_arn=${local.instance_profile} \
  security_group_id=${local.security_group_id} \
  aws_region=${data.aws_region.current.name} \
  aws_key_name=${var.aws_key_name} \
  account_id=${lookup(var.common_tags, "accountid", "0")}"
EOT
  }
}
