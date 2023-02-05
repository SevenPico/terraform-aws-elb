output "arn_suffix" {
  value = try(aws_lb_target_group.this[0].arn_suffix, "")
}

output "arn" {
  value = try(aws_lb_target_group.this[0].arn, "")
}

output "id" {
  value = try(aws_lb_target_group.this[0].id, "")
}

output "name" {
  value = try(aws_lb_target_group.this[0].name, "")
}
