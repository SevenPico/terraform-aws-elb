# ------------------------------------------------------------------------------
# Lambda
# ------------------------------------------------------------------------------
resource "aws_lambda_function" "target" {
  function_name = "lambda_function_name"

  role    = aws_iam_role.target_lambda.arn
  handler = "main.lambda_handler"
  runtime = "python3.9"

  filename         = data.archive_file.lambda[0].output_path
  source_code_hash = data.archive_file.lambda[0].output_base64sha256


  environment {
    variables = { foo = "bar" }
  }
}

data "archive_file" "lambda" {
  count       = module.context.enabled ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/.build/lambda.zip"
}

resource "aws_iam_role" "target_lambda" {
  name = "target_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


