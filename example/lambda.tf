# ------------------------------------------------------------------------------
# Lambda
# ------------------------------------------------------------------------------
resource "aws_lambda_function" "target" {
  #checkov:skip=CKV_AWS_272:skipping 'Ensure AWS Lambda function is configured to validate code-signing'
  #checkov:skip=CKV_AWS_116:skipping 'Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)'
  #checkov:skip=CKV_AWS_117:skipping 'Ensure that AWS Lambda function is configured inside a VPC'
  #checkov:skip=CKV_AWS_50:skipping 'X-ray tracing is enabled for Lambda'
  #checkov:skip=CKV_AWS_115:skipping 'Ensure that AWS Lambda function is configured for function-level concurrent execution limit'
  #checkov:skip=CKV_AWS_173:skipping 'Check encryption settings for Lambda environmental variable'
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


