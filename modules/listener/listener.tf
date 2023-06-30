

resource "aws_lb_listener" "this" {
  #checkov:skip=CKV_AWS_2:skipping 'Ensure ALB protocol is HTTPS'
  count = module.context.enabled ? 1 : 0

  load_balancer_arn = var.load_balancer_arn
  tags              = module.context.tags

  port       = var.port
  protocol   = var.protocol
  ssl_policy = var.ssl_policy
  #alpn_policy     = var.alpn_policy
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

variable "rules_count" {
  type    = number
  default = 0
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
  #for_each = module.context.enabled ? { for index, rule in var.rules : index => rule } : {}
  count = module.context.enabled ? var.rules_count : 0 # length(var.rules) : 0


  listener_arn = aws_lb_listener.this[0].arn
  tags         = module.context.tags
  priority     = try(var.rules[count.index].priority, null)

  action {
    type             = var.rules[count.index].type
    target_group_arn = var.rules[count.index].target_group_arn

    dynamic "redirect" {
      for_each = var.rules[count.index].redirect != null ? [1] : []
      content {
        host        = var.rules[count.index].redirect.host
        path        = var.rules[count.index].redirect.path
        port        = var.rules[count.index].redirect.port
        protocol    = var.rules[count.index].redirect.protocol
        query       = var.rules[count.index].redirect.query
        status_code = var.rules[count.index].redirect.is_permanent ? "HTTP_301" : "HTTP_302"
      }
    }

    dynamic "fixed_response" {
      for_each = var.rules[count.index].fixed_response != null ? [1] : []
      content {
        content_type = var.rules[count.index].fixed_response.content_type
        message_body = var.rules[count.index].fixed_response.message_body
        status_code  = var.rules[count.index].fixed_response.status_code
      }
    }
  }

  dynamic "condition" {
    for_each = var.rules[count.index].conditions
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
