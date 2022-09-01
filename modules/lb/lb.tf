
resource "aws_lb" "this" {
  count = module.context.enabled ? 1 : 0

  name        = module.context.id
  tags        = module.context.tags
  name_prefix = null # dont use

  internal                         = var.internal
  load_balancer_type               = var.type
  security_groups                  = var.security_groups
  subnets                          = var.subnet_ids
  drop_invalid_header_fields       = var.drop_invalid_header_fields
  preserve_host_header             = var.preserve_host_header
  idle_timeout                     = var.idle_timeout
  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                     = var.enable_http2
  enable_waf_fail_open             = var.enable_waf_fail_open
  customer_owned_ipv4_pool         = var.customer_owned_ipv4_pool
  ip_address_type                  = var.ip_address_type
  desync_mitigation_mode           = var.desync_mitigation_mode

  access_logs {
    enabled = var.access_logs_enabled
    bucket  = var.access_logs_bucket_id
    prefix  = "todo"
  }

  dynamic "subnet_mapping" {
    for_each = toset(module.context.enabled ? var.subnet_mappings : [])

    content {
      subnet_id            = subnet_mapping.subnet_id
      allocation_id        = subnet_mapping.allocation_id
      private_ipv4_address = subnet_mapping.private_ipv4_address
      ipv6_address         = subnet_mapping.ipv6_address
    }
  }
}
