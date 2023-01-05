# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "lb" {
  source  = "../"
  context = module.context.self
  name    = "foo"

  security_group_ids               = [module.lb_security_group.id]
  subnet_ids                       = module.vpc_subnets.public_subnet_ids
  internal                         = false
  drop_invalid_header_fields       = false
  preserve_host_header             = false
  access_logs_enabled              = false
  access_log_bucket_id             = ""
  idle_timeout_seconds             = 60
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = false
  enable_http2                     = true
  enable_waf_fail_open             = false
  customer_owned_ipv4_pool         = ""
  type                             = "application"
  ip_address_type                  = "ipv4"
  desync_mitigation_mode           = "defensive"

  listeners = {
    test-http = {
      port        = 80
      protocol    = "HTTP"

      rules_count = 3
      rules = [
        {
          type = "fixed-response"
          fixed_response = {
            content_type = "text/plain"
            message_body = "This is your fixed response message body."
            status_code  = 200
          }
          conditions = [{
            path_patterns = ["/fixed"]
          }]
        },
        {
          type = "redirect"
          redirect = {
            host         = "wttr.in"
            path         = "/moon"
            port         = 80
            protocol     = "HTTP"
            query        = ""
            is_permanent = true
          }
          conditions = [{
            path_patterns = ["/weather"]
          }]
        },
        {
          type             = "forward"
          target_group_arn = module.lambda_target_group.arn
          # forward = {
          #   target_group_arns   = optional(list(string))
          #   stickiness_enabled  = optional(bool)
          #   stickiness_duration = optional(number)
          # }
          conditions = [{
            path_patterns = ["/forward"]
          }]
        },
      ]
    }

    # test-https = {
    #   port            = 443
    #   protocol        = "HTTPS"
    #   certificate_arn = "" # TODO
    # }
  }
}


# ------------------------------------------------------------------------------
# Lambda Target
# ------------------------------------------------------------------------------
module "lambda_target_group" {
  source     = "../modules/target-group"
  context    = module.context.self
  attributes = ["tg"]

  target_ids  = [aws_lambda_function.target.arn]
  target_type = "lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lambda_permission" "target" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.target.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = module.lambda_target_group.arn
}


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "lb_security_group" {
  source  = "registry.terraform.io/cloudposse/security-group/aws"
  version = "1.0.1"
  context = module.context.self

  allow_all_egress              = false
  create_before_destroy         = true
  inline_rules_enabled          = false
  revoke_rules_on_delete        = false
  rule_matrix                   = []
  rules                         = []
  security_group_create_timeout = "10m"
  security_group_delete_timeout = "15m"
  security_group_description    = "LB"
  security_group_name           = []
  target_security_group_id      = []
  vpc_id                        = module.vpc.vpc_id

  rules_map = {
    ingress-https-from-internet = [{
      description = "Allow ingress from internet on 443"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
    }]
    ingress-http-from-internet = [{
      description = "Allow ingress from internet on 80"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
    }]
  }
}

output "lb" {
  value = module.lb
}
