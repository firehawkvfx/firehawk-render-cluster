terraform {
  required_providers {
    aws = "~> 3.8" # specifically because this fix can simplify work arounds - https://github.com/hashicorp/terraform-provider-aws/pull/14314
  }
}

locals {
  name = "s3_gateway_pipeid${lookup(var.common_tags, "pipelineid", "0")}"
  extra_tags = {
    role  = "fsx"
    route = "private"
  }
}

locals {
  cloud_s3_gateway_enabled = (!var.sleep && var.cloud_s3_gateway_enabled) ? 1 : 0
}

data "aws_vpc" "deployment_vpc" {
  id = var.vpc_id
}

data "aws_ami" "gateway_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["aws-thinstaller-1528922603"]
  }
}

resource "aws_instance" "gateway" {
  ami           = data.aws_ami.gateway_ami.image_id
  instance_type = var.instance_type

  # Refer to AWS File Gateway documentation for minimum system requirements.
  ebs_optimized = true
  subnet_id     = length(var.subnet_ids) > 0 ? var.subnet_ids[0] : null

  ebs_block_device {
    device_name           = "/dev/xvdf"
    volume_size           = var.ebs_cache_volume_size
    volume_type           = "gp2"
    delete_on_termination = true
  }

  key_name = var.key_name

  vpc_security_group_ids = [
    "${aws_security_group.storage_gateway.id}",
  ]
}

resource "aws_storagegateway_gateway" "nfs_file_gateway" {
  gateway_ip_address = aws_instance.gateway.private_ip
  gateway_name       = var.gateway_name
  gateway_timezone   = var.gateway_time_zone
  gateway_type       = "FILE_S3"
}

data "aws_storagegateway_local_disk" "cache" {
  disk_path   = "/dev/xvdf"
  disk_node   = "/dev/xvdf"
  gateway_arn = aws_storagegateway_gateway.nfs_file_gateway.id
}

resource "aws_storagegateway_cache" "nfs_cache_volume" {
  disk_id     = data.aws_storagegateway_local_disk.cache.id
  gateway_arn = aws_storagegateway_gateway.nfs_file_gateway.id
}

# resource "aws_route53_record" "gateway_A_record" {
#   zone_id = data.aws_route53_zone.zone_name.zone_id
#   name    = var.gateway_name
#   type    = "A"
#   ttl     = "3600"
#   records = ["${aws_instance.gateway.private_ip}"]
# }

resource "aws_storagegateway_nfs_file_share" "same_account" {
  client_list  = var.permitted_cidr_list_private
  gateway_arn  = aws_storagegateway_gateway.nfs_file_gateway.id
  role_arn     = aws_iam_role.role.arn
  location_arn = var.aws_s3_bucket_arn
}
