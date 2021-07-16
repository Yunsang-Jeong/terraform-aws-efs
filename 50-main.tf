resource "aws_efs_file_system" "this" {

  # Encryption
  encrypted = var.encrypted
  kms_key_id = var.kms_key_id

  # Performance
  throughput_mode = var.throughput_mode
  performance_mode = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps

  # General
  availability_zone_name = var.availability_zone_name
  creation_token = var.creation_token
  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy == null ? toset([]) : toset([var.lifecycle_policy])
    content {
      # transition_to_ia - (required) is a type of string
      transition_to_ia = lifecycle_policy.value["transition_to_ia"]
    }
  }
  tags = merge(
    var.global_additional_tag,
    var.tags, {
      "Name" = join("-", compact(["efs", local.name_tag_middle, var.name_tag_postfix]))
    }
  )
}

resource "aws_efs_mount_target" "this" {
  for_each = var.subnet_ids
  
  file_system_id = aws_efs_file_system.this.id
  subnet_id = each.value
  ip_address = var.ip_address
  security_groups = var.security_group_ids
}