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

