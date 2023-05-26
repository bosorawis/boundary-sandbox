data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "./bin/lambda"
  output_path = "./bin/lambda.zip"
}

resource "aws_lambda_function" "worker_auth_watcher_lambda" {
  function_name    = "worker-auth-watcher"
  filename         = "./bin/lambda.zip"
  handler          = "lambda"
  source_code_hash = "data.archive_file.lambda_zip.output_base64sha256"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 10
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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