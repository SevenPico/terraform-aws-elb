
/*
  listeners = {
    api = {
      port                        = 443
      protocol                    = "HTTPS"
      certificate_arn             = "" # TODO
      additional_certificate_arns = []
      alpn_policy                 = ""
      ssl_policy                  = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

      actions = {
        default = {
          # type                 - (Required) Type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc.
          # target_group_arn     - (Optional) ARN of the Target Group to which to route traffic. Specify only if type is forward and you want to route to a single target group. To route to one or more target groups, use a forward block instead.

          # forward              - (Optional) Configuration block for creating an action that distributes requests among one or more target groups. Specify only if type is forward. If you specify both forward block and target_group_arn attribute, you can specify only one target group using forward and it must be the same target group specified in target_group_arn. Detailed below.
          # redirect             - (Optional) Configuration block for creating a redirect action. Required if type is redirect. Detailed below.
          # fixed_response       - (Optional) Information for creating an action that returns a custom HTTP response. Required if type is fixed-response.
          # authenticate_cognito - (Optional) Configuration block for using Amazon Cognito to authenticate users. Specify only when type is authenticate-cognito. Detailed below.
          # authenticate_oidc    - (Optional) Configuration block for an identity provider that is compliant with OpenID Connect (OIDC). Specify only when type is authenticate-oidc. Detailed below.

          priority = 1
          conditions = {
            payter-path = {
              path_pattern = "/payter/*"
            }
          }

        }
        payment = {
          forward = {
            target_groups = {
              payment-service = {
                arn    = ""
                weight = 0
              }
            }
            stickiness_enabled  = false
            stickiness_duration = 60 # seconds
          }
        }
      }
    }
  }

  targets = {
    # target_group_key
    # target_group_arn  - (Required) The ARN of the target group with which to register targets
    # target_id         - (Required) The ID of the target. This is the Instance ID for an instance, or the container ID for an ECS container. If the target type is ip, specify an IP address. If the target type is lambda, specify the arn of lambda. If the target type is alb, specify the arn of alb.
    # port              - (Optional) The port on which targets receive traffic.
    # availability_zone - (Optional) The Availability Zone where the IP address of the target is to be registered. If the private ip address is outside of the VPC scope, this value must be set to 'all'.
  }

  target_groups = {
    # vpc_id                             - (Optional, Forces new resource) Identifier of the VPC in which to create the target group. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda.
    # connection_termination             - (Optional) Whether to terminate connections at the end of the deregistration timeout on Network Load Balancers. See doc for more information. Default is false.
    # deregistration_delay               - (Optional) Amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 300 seconds.
    # lambda_multi_value_headers_enabled - (Optional) Whether the request and response headers exchanged between the load balancer and the Lambda function include arrays of values or strings. Only applies when target_type is lambda. Default is false.
    # load_balancing_algorithm_type      - (Optional) Determines how the load balancer selects targets when routing requests. Only applicable for Application Load Balancer Target Groups. The value is round_robin or least_outstanding_requests. The default is round_robin.
    # name_prefix                        - (Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name. Cannot be longer than 6 characters.
    # name                               - (Optional, Forces new resource) Name of the target group. If omitted, Terraform will assign a random, unique name.
    # port                               - (May be required, Forces new resource) Port on which targets receive traffic, unless overridden when registering a specific target. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda.
    # preserve_client_ip                 - (Optional) Whether client IP preservation is enabled. See doc for more information.
    # protocol_version                   - (Optional, Forces new resource) Only applicable when protocol is HTTP or HTTPS. The protocol version. Specify GRPC to send requests to targets using gRPC. Specify HTTP2 to send requests to targets using HTTP/2. The default is HTTP1, which sends requests to targets using HTTP/1.1
    # protocol                           - (May be required, Forces new resource) Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda.
    # proxy_protocol_v2                  - (Optional) Whether to enable support for proxy protocol v2 on Network Load Balancers. See doc for more information. Default is false.
    # slow_start                         - (Optional) Amount time for targets to warm up before the load balancer sends them a full share of requests. The range is 30-900 seconds or 0 to disable. The default value is 0 seconds.
    # target_failover                    - (Optional) Target failover block. Only applicable for Gateway Load Balancer target groups. See target_failover for more information.
    # target_type                        - (May be required, Forces new resource) Type of target that you must specify when registering targets with this target group. See doc for supported values. The default is instance.
    # ip_address_type                    - (Optional, forces new resource) The type of IP addresses used by the target group, only supported when target type is set to ip. Possible values are ipv4 or ipv6.

    health_check = {
      # enabled             - (Optional) Whether health checks are enabled. Defaults to true.
      # healthy_threshold   - (Optional) Number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3.
      # interval            - (Optional) Approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. For lambda target groups, it needs to be greater as the timeout of the underlying lambda. Default 30 seconds.
      # matcher             - (May be required) Response codes to use when checking for a healthy responses from a target. You can specify multiple values (for example, "200,202" for HTTP(s) or "0,12" for GRPC) or a range of values (for example, "200-299" or "0-99"). Required for HTTP/HTTPS/GRPC ALB. Only applies to Application Load Balancers (i.e., HTTP/HTTPS/GRPC) not Network Load Balancers (i.e., TCP).
      # path                - (May be required) Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS.
      # port                - (Optional) Port to use to connect with the target. Valid values are either ports 1-65535, or traffic-port. Defaults to traffic-port.
      # protocol            - (Optional) Protocol to use to connect with the target. Defaults to HTTP. Not applicable when target_type is lambda.
      # timeout             - (Optional) Amount of time, in seconds, during which no response means a failed health check. For Application Load Balancers, the range is 2 to 120 seconds, and the default is 5 seconds for the instance target type and 30 seconds for the lambda target type. For Network Load Balancers, you cannot set a custom value, and the default is 10 seconds for TCP and HTTPS health checks and 5 seconds for HTTP health checks.
      # unhealthy_threshold - (Optional) Number of consecutive health check failures required before considering the target unhealthy. For Network Load Balancers, this value must be the same as the healthy_threshold. Defaults to 3.
    }

    stickiness = {
      # cookie_duration - (Optional) Only used when the type is lb_cookie. The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to 1 week (604800 seconds). The default value is 1 day (86400 seconds).
      # cookie_name     - (Optional) Name of the application based cookie. AWSALB, AWSALBAPP, and AWSALBTG prefixes are reserved and cannot be used. Only needed when type is app_cookie.
      # enabled         - (Optional) Boolean to enable / disable stickiness. Default is true.
      # type            - (Required) The type of sticky sessions. The only current possible values are lb_cookie, app_cookie for ALBs, source_ip for NLBs, and source_ip_dest_ip, source_ip_dest_ip_proto for GWLBs.
    }
  }
  */
