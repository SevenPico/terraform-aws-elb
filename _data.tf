
data "aws_caller_identity" "current" { count = module.context.enabled ? 1 : 0 }
data "aws_partition" "current" { count = module.context.enabled ? 1 : 0 }
data "aws_canonical_user_id" "default" { count = module.context.enabled ? 1 : 0 }
