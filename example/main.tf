output "lb" {
  value = module.lb
}


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
      port     = 80
      protocol = "HTTP"
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
        # {
        #   type             = "forward"
        #   target_group_arn = "FIXME"
        #   # forward = {
        #   #   target_group_arns   = optional(list(string))
        #   #   stickiness_enabled  = optional(bool)
        #   #   stickiness_duration = optional(number)
        #   # }
        #   conditions = [{
        #     path_patterns = ["/forward"]
        #   }]
        # },
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
# ------------------------------------------------------------------------------


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


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "vpc" {
  source     = "registry.terraform.io/cloudposse/vpc/aws"
  version    = "1.1.1"
  context    = module.context.legacy
  attributes = ["vpc"]

  cidr_block                                      = "10.0.0.0/16"
  additional_cidr_blocks                          = []
  assign_generated_ipv6_cidr_block                = false
  classiclink_dns_support_enabled                 = false
  classiclink_enabled                             = false
  default_security_group_deny_all                 = true
  dns_hostnames_enabled                           = true
  dns_support_enabled                             = true
  enable_classiclink                              = false
  enable_default_security_group_with_custom_rules = false
  enable_classiclink_dns_support                  = false
  enable_dns_hostnames                            = true
  enable_dns_support                              = true
  enable_internet_gateway                         = true
  instance_tenancy                                = "default"
  internet_gateway_enabled                        = true
  ipv6_egress_only_internet_gateway_enabled       = false
  ipv6_enabled                                    = true
}

module "vpc_subnets" {
  source     = "registry.terraform.io/cloudposse/dynamic-subnets/aws"
  version    = "0.39.8"
  context    = module.context.legacy
  attributes = ["vpc", "subnets"]

  availability_zones                   = ["us-east-1a", "us-east-1b"]
  cidr_block                           = "10.0.0.0/16"
  igw_id                               = module.vpc.igw_id
  vpc_id                               = module.vpc.vpc_id
  availability_zone_attribute_style    = "short"
  aws_route_create_timeout             = "2m"
  aws_route_delete_timeout             = "2m"
  map_public_ip_on_launch              = false
  max_subnet_count                     = 0
  metadata_http_endpoint_enabled       = false
  metadata_http_put_response_hop_limit = 1
  metadata_http_tokens_required        = true
  nat_elastic_ips                      = []
  nat_gateway_enabled                  = true
  nat_instance_enabled                 = false
  nat_instance_type                    = "t3.micro"
  private_network_acl_id               = ""
  private_subnets_additional_tags      = {}
  public_network_acl_id                = ""
  public_subnets_additional_tags       = {}
  root_block_device_encrypted          = true
  subnet_type_tag_key                  = "Type"
  subnet_type_tag_value_format         = "%s"
  vpc_default_route_table_id           = ""
}
