variable "type" {
  type    = string
  default = "application"

  validation {
    condition     = contains(["application"], var.type)
    error_message = "The 'type' must be one of [application]."
  }
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "internal" {
  type    = bool
  default = false
}

variable "drop_invalid_header_fields" {
  type    = bool
  default = false
}

variable "preserve_host_header" {
  type    = bool
  default = false
}

variable "access_logs_enabled" {
  type    = string
  default = false
}

variable "access_log_bucket_id" {
  type    = string
  default = ""
}

variable "idle_timeout_seconds" {
  type    = number
  default = 60
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}

variable "enable_cross_zone_load_balancing" {
  type    = bool
  default = false
}

variable "enable_http2" {
  type    = bool
  default = true
}

variable "enable_waf_fail_open" {
  type    = bool
  default = false
}

variable "customer_owned_ipv4_pool" {
  type    = string
  default = ""
}

variable "ip_address_type" {
  type    = string
  default = "ipv4"
}

variable "desync_mitigation_mode" {
  type    = string
  default = "defensive"
}

/*
variable "target_groups" {
  type = map(object({
    port            = number
    protocol        = string
    ssl_policy      = string
    certificate_arn = string
    # ...

    targets = list(object({
      vpc_id = string
      # ...
    }))
  }))
}

variable "targets" {
  type = map(object({
    port            = number
    protocol        = string
    ssl_policy      = string
    certificate_arn = string
    # ...

    targets = list(object({
      vpc_id = string
      # ...
    }))
  }))
}
*/

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
output "arn" {
  value = try(aws_lb.this[0].arn, "")
}

output "arn_suffix" {
  value = try(aws_lb.this[0].arn_suffix, "")
}

output "dns_name" {
  value = try(aws_lb.this[0].dns_name, "")
}

output "id" {
  value = try(aws_lb.this[0].id, "")
}

output "zone_id" {
  value = try(aws_lb.this[0].zone_id, "")
}



# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

locals {
  default_logs_prefix = join("/", compact([
    try(data.aws_caller_identity.current[0].account_id, ""),
    "${module.context.id}/"
  ]))
}

resource "aws_lb" "this" {
  count = module.context.enabled ? 1 : 0

  name        = module.context.id
  tags        = module.context.tags
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
  #   for_each = toset(module.context.enabled ? var.subnet_mappings : [])

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

variable "listeners" {
  default = {}
  type    = any
  # map(object({
  #   port                        = number
  #   protocol                    = string
  #   certificate_arn             = optional(string)
  #   additional_certificate_arns = optional(list(string))
  #   ssl_policy                  = optional(string)
  #   alpn_policy                 = optional(string)
  #   rules                       = any #optional(list(any))
  #   rules_count                 = number

  #   # targets = list(object({
  #   #   vpc_id = string
  #   #   # ...
  #   # }))
  # }))
}

module "listeners" {
  source  = "./modules/listener"
  context = module.context.self

  for_each = module.context.enabled ? var.listeners : {}

  load_balancer_arn = aws_lb.this[0].arn

  port       = try(each.value.port, "443")
  protocol   = try(each.value.protocol, "HTTPS")
  ssl_policy = try(each.value.ssl_policy, "ELBSecurityPolicy-TLS-1-2-Ext-2018-06")
  #FIXME alpn_policy     = try(each.value.alpn_policy, "HTTP2Preferred")
  certificate_arn = try(each.value.certificate_arn, null)
  rules           = try(each.value.rules, [])
  rules_count     = try(each.value.rules_count, [])
}
