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


variable "rules" {
  default = {}
  type = list(object({
    type = string

    forward = optional(object({
      target_group_arns   = optional(list(string))
      stickiness_enabled  = optional(bool)
      stickiness_duration = optional(number)
    }))

    redirect = optional(object({
      host        = optional(string)
      path        = optional(string)
      port        = optional(string)
      protocol    = optional(string)
      query       = optional(string)
      status_code = optional(string)
    }))

    fixed = optional(object({
      content_type = string
      message_body = string
      status_code  = number
    }))

    # TODO - authenticate-cognito
    # TODO - authenticate-oidc

    conditions = list(object({
      http_headers  = optional(map(string))
      query_strings = optional(map(string))
      host_headers  = optional(list(string))
      http_methods  = optional(list(string))
      path_patterns = optional(list(string))
      source_ips    = optional(list(string))
    }))
  }))
}


resource "aws_lb_listener_rule" "this" {
  for_each = module.context.enabled ? var.rules : {}

  listener_arn = aws_lb_listener.this[0].arn
  tags         = module.context.tags
  priority     = try(each.value.priority, null)

  action {
    type = each.value.type

    # dynamic "forward" {
    #   for_each = each.value.forward != null ? [1] : []
    # }

    # dynamic "redirect" {
    # }

    dynamic "fixed" {
      for_each = each.value.forward != null ? [1] : []
      content {
        content_type = each.value.fixed.content_type
        message_body = each.value.fixed.message_body
        status_code  = each.value.fixed.status_code
      }
    }
  }

  # dynamic "condition" {
  #   for_each = each.value.conditions

  #   content {

  #   }
  # }


  # action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.static.arn
  # }

  # condition {
  #   path_pattern {
  #     values = ["/static/*"]
  #   }
  # }

  # condition {
  #   host_header {
  #     values = ["example.com"]
  #   }
  # }
}






























# Forward action

resource "aws_lb_listener_rule" "host_based_weighted_routing" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.static.arn
  }

  condition {
    host_header {
      values = ["my-service.*.terraform.io"]
    }
  }
}

# Weighted Forward action

resource "aws_lb_listener_rule" "host_based_routing" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 99

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.main.arn
        weight = 80
      }

      target_group {
        arn    = aws_lb_target_group.canary.arn
        weight = 20
      }

      stickiness {
        enabled  = true
        duration = 600
      }
    }
  }

  condition {
    host_header {
      values = ["my-service.*.terraform.io"]
    }
  }
}

# Redirect action

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  listener_arn = aws_lb_listener.front_end.arn

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    http_header {
      http_header_name = "X-Forwarded-For"
      values           = ["192.168.1.*"]
    }
  }
}

# Fixed-response action

resource "aws_lb_listener_rule" "health_check" {
  listener_arn = aws_lb_listener.front_end.arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "HEALTHY"
      status_code  = "200"
    }
  }

  condition {
    query_string {
      key   = "health"
      value = "check"
    }

    query_string {
      value = "bar"
    }
  }
}

# Authenticate-cognito Action

resource "aws_cognito_user_pool" "pool" {
  # ...
}

resource "aws_cognito_user_pool_client" "client" {
  # ...
}

resource "aws_cognito_user_pool_domain" "domain" {
  # ...
}

resource "aws_lb_listener_rule" "admin" {
  listener_arn = aws_lb_listener.front_end.arn

  action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.pool.arn
      user_pool_client_id = aws_cognito_user_pool_client.client.id
      user_pool_domain    = aws_cognito_user_pool_domain.domain.domain
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.static.arn
  }
}

# Authenticate-oidc Action

resource "aws_lb_listener_rule" "oidc" {
  listener_arn = aws_lb_listener.front_end.arn

  action {
    type = "authenticate-oidc"

    authenticate_oidc {
      authorization_endpoint = "https://example.com/authorization_endpoint"
      client_id              = "client_id"
      client_secret          = "client_secret"
      issuer                 = "https://example.com"
      token_endpoint         = "https://example.com/token_endpoint"
      user_info_endpoint     = "https://example.com/user_info_endpoint"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.static.arn
  }
}
