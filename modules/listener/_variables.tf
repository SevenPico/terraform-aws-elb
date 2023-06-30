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
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "alpn_policy" {
  type    = string
  default = "HTTP2Preferred"
}

variable "certificate_arn" {
  type    = string
  default = ""
}
