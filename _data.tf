
data "aws_caller_identity" "current" { count = data.context.this.enabled ? 1 : 0 }
data "aws_partition" "current" { count = data.context.this.enabled ? 1 : 0 }
data "aws_canonical_user_id" "default" { count = data.context.this.enabled ? 1 : 0 }
