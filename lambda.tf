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
  role             = "${aws_iam_role.lambda_execution_role.arn}"
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 10
  environment {
    variables = {
      CLUSTER_URL             = "https://${var.hcp_boundary_cluster_id}.boundary.hashicorp.cloud"
      BOUNDARY_USERNAME       = var.hcp_boundary_username
      BOUNDARY_PASSWORD       = var.hcp_boundary_password
      BOUNDARY_AUTH_MATHOD_ID = var.hcp_boundary_auth_method
    }
  }
}

resource "aws_dynamodb_table" "dynamo" {
  name         = "GameScores"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  attribute {
    name = "pk"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_execution_role" {
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

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
