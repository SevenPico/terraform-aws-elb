variable "load_balancer_arn" {
  type = string
}

variable "port" {
  type    = string
  default = null
}

variable "protocol" {
  type    = string
  default = null
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

variable "alpn_policy" {
  type    = string
  default = "HTTP2Preferred"
}

variable "certificate_arn" {
  type    = string
  default = ""
}


resource "aws_lb_listener" "this" {
  count = module.context.enabled ? 1 : 0

  load_balancer_arn = var.load_balancer_arn
  tags              = module.context.tags

  port            = var.port
  protocol        = var.protocol
  ssl_policy      = var.ssl_policy
  alpn_policy     = var.alpn_policy
  certificate_arn = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Unimplemented"
      status_code  = 200
    }
  }
}


# rule = action + condition
variable "rules" {
  default = []
  type = list(object({
    type = string

    target_group_arn = optional(string)
    # TODO - forward options
    # forward = optional(object({
    #   target_group_arns   = optional(list(string))
    #   stickiness_enabled  = optional(bool)
    #   stickiness_duration = optional(number)
    # }))

    redirect = optional(object({
      host         = optional(string)
      path         = optional(string)
      port         = optional(string)
      protocol     = optional(string)
      query        = optional(string)
      is_permanent = optional(bool)
    }))

    fixed_response = optional(object({
      content_type = string
      message_body = string
      status_code  = number
    }))

    # TODO - authenticate-cognito
    # TODO - authenticate-oidc

    conditions = list(object({
      path_patterns = optional(list(string))

      # TODO - http_headers  = optional(map(string))
      # TODO - query_strings = optional(map(string))
      # TODO - host_headers  = optional(list(string))
      # TODO - http_methods  = optional(list(string))
      # TODO - source_ips    = optional(list(string))
    }))
  }))
}

resource "aws_lb_listener_rule" "this" {
  for_each = module.context.enabled ? { for index, rule in var.rules : index => rule } : {}

  listener_arn = aws_lb_listener.this[0].arn
  tags         = module.context.tags
  priority     = try(each.value.priority, null)

  action {
    type             = each.value.type
    target_group_arn = each.value.target_group_arn

    # TODO
    # dynamic "forward" {
    #   for_each = each.value.forward != null ? [1] : []
    #   content {
    #   }
    # }

    dynamic "redirect" {
      for_each = each.value.redirect != null ? [1] : []
      content {
        host        = each.value.redirect.host
        path        = each.value.redirect.path
        port        = each.value.redirect.port
        protocol    = each.value.redirect.protocol
        query       = each.value.redirect.query
        status_code = each.value.redirect.is_permanent ? "HTTP_301" : "HTTP_302"
      }
    }


    dynamic "fixed_response" {
      for_each = each.value.fixed_response != null ? [1] : []
      content {
        content_type = each.value.fixed_response.content_type
        message_body = each.value.fixed_response.message_body
        status_code  = each.value.fixed_response.status_code
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.conditions

    content {
      dynamic "path_pattern" {
        for_each = condition.value.path_patterns != null ? [1] : []
        content {
          values = condition.value.path_patterns
        }
      }
    }
  }
}
