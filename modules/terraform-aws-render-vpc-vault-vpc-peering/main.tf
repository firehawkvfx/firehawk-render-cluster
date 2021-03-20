provider "aws" {
  #  if you haven't installed and configured the aws cli, you will need to provide your aws access key and secret key.
  # in a dev environment these version locks below can be disabled.  in production, they should be locked based on the suggested versions from terraform init.
  version = "~> 3.15.0"
}
locals {
  common_tags = var.common_tags
  vaultvpc_tags = {
    "conflictkey" : local.common_tags["conflictkey"],
    "pipelineid" : local.common_tags["pipelineid"],
    "projectname" : "firehawk-main",
    "vpcname": var.vpcname_vault,
  }
}
data "aws_vpc" "primary" { # The primary is the VPC defined by the common tags var.
  default = false
  tags    = local.common_tags
}
data "aws_vpc" "secondary" { # The secondary VPC
  default = false
  tags    = local.vaultvpc_tags
}
resource "aws_vpc_peering_connection" "primary2secondary" {
  vpc_id      = data.aws_vpc.primary.id   # Primary VPC ID.
  peer_vpc_id = data.aws_vpc.secondary.id # Secondary VPC ID.
  auto_accept = true                      # Flags that the peering connection should be automatically confirmed. This only works if both VPCs are owned by the same account.

  # # AWS Account ID. This can be dynamically queried using the
  # # aws_caller_identity data resource.
  # # https://www.terraform.io/docs/providers/aws/d/caller_identity.html
  # peer_owner_id = "${data.aws_caller_identity.current.account_id}"
}
data "aws_route_table" "primary_private" {
  tags = merge( local.common_tags, { "area" : "private" } )
}
data "aws_route_table" "primary_public" {
  tags = merge( local.common_tags, { "area" : "public" } )
}
resource "aws_route" "primaryprivate2secondary" {
  route_table_id            = data.aws_route_table.primary_private.id
  destination_cidr_block    = data.aws_vpc.secondary.cidr_block               # CIDR block / IP range for VPC 2.
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2secondary.id # ID of VPC peering connection.
}
resource "aws_route" "primarypublic2secondary" {
  route_table_id            = data.aws_route_table.primary_public.id
  destination_cidr_block    = data.aws_vpc.secondary.cidr_block               # CIDR block / IP range for VPC 2.
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2secondary.id # ID of VPC peering connection.
}
data "aws_route_table" "secondary_private" {
  tags = merge( local.vaultvpc_tags, { "area" : "private" } )
}

data "aws_route_table" "secondary_public" {
  tags = merge( local.vaultvpc_tags, { "area" : "public" } )
}
resource "aws_route" "secondaryprivate2primary" {
  route_table_id            = data.aws_route_table.secondary_private.id
  destination_cidr_block    = data.aws_vpc.primary.cidr_block               # CIDR block / IP range for VPC 2.
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2secondary.id # ID of VPC peering connection.
}
resource "aws_route" "secondarypublic2primary" {
  route_table_id            = data.aws_route_table.secondary_public.id
  destination_cidr_block    = data.aws_vpc.primary.cidr_block               # CIDR block / IP range for VPC 2.
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2secondary.id # ID of VPC peering connection.
}