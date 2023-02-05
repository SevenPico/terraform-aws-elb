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
