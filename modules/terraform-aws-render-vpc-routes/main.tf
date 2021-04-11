data "aws_vpc" "primary" {
  default = false
  tags    = var.common_tags_rendervpc
}
data "aws_route_tables" "public" {
  vpc_id = data.aws_vpc.primary.id
  tags   = merge(var.common_tags_rendervpc, { "area" : "public" })
}

data "aws_route_tables" "private" {
  vpc_id = data.aws_vpc.primary.id
  tags   = merge(var.common_tags_rendervpc, { "area" : "private" })
}

data "aws_instance" "vpn" {
  tags = merge(var.common_tags_vaultvpc, { "role" : "vpn" })
}

locals {
  private_route_table_ids = sort(data.aws_route_tables.private.ids)
  public_route_table_ids  = sort(data.aws_route_tables.public.ids)
  id                      = data.aws_instance.vpn.id
}

# Route tables to send traffic to the remote subnet are configured once the vpn is provisioned.

resource "aws_route" "private_openvpn_remote_subnet_gateway" {
  count = length(local.private_route_table_ids)

  route_table_id         = element(concat(local.private_route_table_ids, list("")), count.index)
  destination_cidr_block = var.onsite_private_subnet_cidr
  instance_id            = local.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "public_openvpn_remote_subnet_gateway" {
  count = length(local.public_route_table_ids)

  route_table_id         = element(concat(local.public_route_table_ids, list("")), count.index)
  destination_cidr_block = var.onsite_private_subnet_cidr
  instance_id            = local.id

  timeouts {
    create = "5m"
  }
}

### routes may be needed for traffic going back to open vpn dhcp adresses
resource "aws_route" "private_openvpn_remote_subnet_vpndhcp_gateway" {
  count = length(local.private_route_table_ids)

  route_table_id         = element(concat(local.private_route_table_ids, list("")), count.index)
  destination_cidr_block = var.vpn_cidr
  instance_id            = local.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "public_openvpn_remote_subnet_vpndhcp_gateway" {
  count = length(local.public_route_table_ids)

  route_table_id         = element(concat(local.public_route_table_ids, list("")), count.index)
  destination_cidr_block = var.vpn_cidr
  instance_id            = local.id

  timeouts {
    create = "5m"
  }
}
