

resource "aws_lb_target_group" "this" {
  count = module.context.enabled ? 1 : 0

  name        = module.context.id
  tags        = module.context.tags
  name_prefix = null # don't use

  vpc_id      = var.vpc_id
  target_type = var.target_type

  # connection_termination             - (Optional) Whether to terminate connections at the end of the deregistration timeout on Network Load Balancers. See doc for more information. Default is false.
  # deregistration_delay               - (Optional) Amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 300 seconds.
  # lambda_multi_value_headers_enabled - (Optional) Whether the request and response headers exchanged between the load balancer and the Lambda function include arrays of values or strings. Only applies when target_type is lambda. Default is false.
  # load_balancing_algorithm_type      - (Optional) Determines how the load balancer selects targets when routing requests. Only applicable for Application Load Balancer Target Groups. The value is round_robin or least_outstanding_requests. The default is round_robin.
  # port                               - (May be required, Forces new resource) Port on which targets receive traffic, unless overridden when registering a specific target. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda.
  # preserve_client_ip                 - (Optional) Whether client IP preservation is enabled. See doc for more information.
  # protocol_version                   - (Optional, Forces new resource) Only applicable when protocol is HTTP or HTTPS. The protocol version. Specify GRPC to send requests to targets using gRPC. Specify HTTP2 to send requests to targets using HTTP/2. The default is HTTP1, which sends requests to targets using HTTP/1.1
  # protocol                           - (May be required, Forces new resource) Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda.
  # proxy_protocol_v2                  - (Optional) Whether to enable support for proxy protocol v2 on Network Load Balancers. See doc for more information. Default is false.
  # slow_start                         - (Optional) Amount time for targets to warm up before the load balancer sends them a full share of requests. The range is 30-900 seconds or 0 to disable. The default value is 0 seconds.
  # ip_address_type                    - (Optional, forces new resource) The type of IP addresses used by the target group, only supported when target type is set to ip. Possible values are ipv4 or ipv6.


  # health_check (optional)
  # enabled - (Optional) Whether health checks are enabled. Defaults to true.
  # healthy_threshold - (Optional) Number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3.
  # interval - (Optional) Approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. For lambda target groups, it needs to be greater as the timeout of the underlying lambda. Default 30 seconds.
  # matcher (May be required) Response codes to use when checking for a healthy responses from a target. You can specify multiple values (for example, "200,202" for HTTP(s) or "0,12" for GRPC) or a range of values (for example, "200-299" or "0-99"). Required for HTTP/HTTPS/GRPC ALB. Only applies to Application Load Balancers (i.e., HTTP/HTTPS/GRPC) not Network Load Balancers (i.e., TCP).
  # path - (May be required) Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS.
  # port - (Optional) Port to use to connect with the target. Valid values are either ports 1-65535, or traffic-port. Defaults to traffic-port.
  # protocol - (Optional) Protocol to use to connect with the target. Defaults to HTTP. Not applicable when target_type is lambda.
  # timeout - (Optional) Amount of time, in seconds, during which no response means a failed health check. For Application Load Balancers, the range is 2 to 120 seconds, and the default is 5 seconds for the instance target type and 30 seconds for the lambda target type. For Network Load Balancers, you cannot set a custom value, and the default is 10 seconds for TCP and HTTPS health checks and 5 seconds for HTTP health checks.
  # unhealthy_threshold - (Optional) Number of consecutive health check failures required before considering the target unhealthy. For Network Load Balancers, this value must be the same as the healthy_threshold. Defaults to 3.

  # stickiness (optional)
  # NOTE: Currently, an NLB (i.e., protocol of HTTP or HTTPS) can have an invalid stickiness block with type set to lb_cookie as long as enabled is set to false. However, please update your configurations to avoid errors in a future version of the provider: either remove the invalid stickiness block or set the type to source_ip.
  # cookie_duration - (Optional) Only used when the type is lb_cookie. The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to 1 week (604800 seconds). The default value is 1 day (86400 seconds).
  # cookie_name     - (Optional) Name of the application based cookie. AWSALB, AWSALBAPP, and AWSALBTG prefixes are reserved and cannot be used. Only needed when type is app_cookie.
  # enabled         - (Optional) Boolean to enable / disable stickiness. Default is true.
  # type            - (Required) The type of sticky sessions. The only current possible values are lb_cookie, app_cookie for ALBs, and source_ip for NLBs.

  # Attributes Reference
  # arn_suffix - ARN suffix for use with CloudWatch Metrics.
}


resource "aws_lb_target_group_attachment" "this" {
  count = module.context.enabled ? length(var.target_ids) : 0

  target_group_arn = aws_lb_target_group.this[0].arn
  target_id        = var.target_ids[count.index]

  # port - (Optional) The port on which targets receive traffic.
  # availability_zone - (Optional) The Availability Zone where the IP address of the target is to be registered. If the private ip address is outside of the VPC scope, this value must be set to 'all'.
}
