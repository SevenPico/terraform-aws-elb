# load_balancer_type               - (Optional) The type of load balancer to create. Possible values are application, gateway, or network. The default value is application.
# drop_invalid_header_fields       - (Optional) Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Only valid for Load Balancers of type application.
# preserve_host_header             - (Optional) Indicates whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to the target without any change. Defaults to false.
# idle_timeout                     - (Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60.
# enable_deletion_protection       - (Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false.
# enable_cross_zone_load_balancing - (Optional) If true, cross-zone load balancing of the load balancer will be enabled. This is a network load balancer feature. Defaults to false.
# enable_http2                     - (Optional) Indicates whether HTTP/2 is enabled in application load balancers. Defaults to true.
# enable_waf_fail_open             - (Optional) Indicates whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF. Defaults to false.
# customer_owned_ipv4_pool         - (Optional) The ID of the customer owned ipv4 pool to use for this load balancer.
# ip_address_type                  - (Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack
# desync_mitigation_mode           - (Optional) Determines how the load balancer handles requests that might pose a security risk to an application due to HTTP desync. Valid values are monitor, defensive (default), strictest.


# internal
# type
# security_groups
# subnet_ids
# drop_invalid_header_fields
# preserve_host_header
# idle_timeout
# enable_deletion_protection
# enable_cross_zone_load_balancing
# enable_http2
# enable_waf_fail_open
# customer_owned_ipv4_pool
# ip_address_type
# desync_mitigation_mode
# access_logs_enabled
# access_logs_bucket_id
# subnet_mappings
