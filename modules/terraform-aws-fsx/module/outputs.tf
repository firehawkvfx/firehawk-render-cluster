output "network_interface_ids" {
  value = length(aws_fsx_lustre_file_system.fsx_storage) > 0 ? aws_fsx_lustre_file_system.fsx_storage.*.network_interface_ids : null
}
output "primary_interface" {
  value = local.primary_interface
}
output "fsx_mount_name" {
  value = aws_fsx_lustre_file_system.fsx_storage.mount_name
}
output "fsx_dns_name" {
  value = aws_fsx_lustre_file_system.fsx_storage.fsx_dns_name
}
output "id" {
  depends_on = [
    aws_fsx_lustre_file_system.fsx_storage,
  ]
  value = local.id
}
output "fsx_private_ip" {
  depends_on = [
    aws_fsx_lustre_file_system.fsx_storage,
    local.primary_interface,
    data.aws_network_interface.fsx_primary_interface,
    aws_route53_record.fsx_record
  ]
  value = local.fsx_private_ip
}