# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
locals {
  default_logs_prefix = join("/", compact([
    try(data.aws_caller_identity.current[0].account_id, ""),
    "${data.context.this.name}/"
  ]))
}

resource "aws_lb" "this" {
  count = data.context.this.enabled ? 1 : 0

  name        = data.context.this.name
  tags        = data.context.this.tags
  name_prefix = null # dont use

  internal                         = var.internal
  load_balancer_type               = var.type
  security_groups                  = var.security_group_ids
  subnets                          = var.subnet_ids
  drop_invalid_header_fields       = var.drop_invalid_header_fields
  preserve_host_header             = var.preserve_host_header
  idle_timeout                     = var.idle_timeout_seconds
  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                     = var.enable_http2
  enable_waf_fail_open             = var.enable_waf_fail_open
  customer_owned_ipv4_pool         = var.customer_owned_ipv4_pool
  ip_address_type                  = var.ip_address_type
  desync_mitigation_mode           = var.desync_mitigation_mode

  dynamic "access_logs" {
    for_each = toset(var.access_logs_enabled ? [1] : [])
    content {
      enabled = var.access_logs_enabled
      bucket  = var.access_logs_bucket_id
      prefix  = local.default_logs_prefix
    }
  }

  # dynamic "subnet_mapping" {
  #   for_each = toset(data.context.this.enabled ? var.subnet_mappings : [])

  #   content {
  #     subnet_id            = subnet_mapping.subnet_id
  #     allocation_id        = subnet_mapping.allocation_id
  #     private_ipv4_address = subnet_mapping.private_ipv4_address
  #     ipv6_address         = subnet_mapping.ipv6_address
  #   }
  # }
}


# ------------------------------------------------------------------------------
# Listeners
# ------------------------------------------------------------------------------
module "listeners" {
  source  = "./modules/listener"
  context = data.context.this

  for_each = data.context.this.enabled ? var.listeners : {}

  load_balancer_arn = aws_lb.this[0].arn

  port       = try(each.value.port, "443")
  protocol   = try(each.value.protocol, "HTTPS")
  ssl_policy = try(each.value.ssl_policy, "ELBSecurityPolicy-TLS-1-2-Ext-2018-06")
  #FIXME alpn_policy     = try(each.value.alpn_policy, "HTTP2Preferred")
  certificate_arn = try(each.value.certificate_arn, null)
  rules           = try(each.value.rules, [])
  rules_count     = try(each.value.rules_count, [])
}
