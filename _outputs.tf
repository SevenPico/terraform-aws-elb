output "arn" {
  value = try(aws_lb.this[0].arn, "")
}

output "arn_suffix" {
  value = try(aws_lb.this[0].arn_suffix, "")
}

output "dns_name" {
  value = try(aws_lb.this[0].dns_name, "")
}

output "id" {
  value = try(aws_lb.this[0].id, "")
}

output "zone_id" {
  value = try(aws_lb.this[0].zone_id, "")
}
