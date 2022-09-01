
variable "listeners" {
  type = map(object({
    port            = number
    protocol        = string
    ssl_policy      = string
    certificate_arn = string
      # ...

    targets = list(object({
      vpc_id = string
      # ...
    }))
  }))
}
