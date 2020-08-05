provider "aws" {
  shared_credentials_file = "../credentials"
  region = var.aws_region
}

//Creating log-group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 3
}

//Creating IAM policy for Lambda logging
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for Lambda logging"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

//Creating IAM attachment polcy
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
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


// A script.zip folder will be created in the locla directory
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/greet_lambda.py"
  output_path = "${path.module}/script.zip"
}


// Creating a simple Lambda function
resource "aws_lambda_function" "lambda_greeting" {
  description      = "Lambda function in python"
  role             = aws_iam_role.iam_for_lambda.arn
  filename         = "script.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = var.lambda_function_name
  handler          = "${var.lambda_function_name}.lambda_handler"
  runtime          = "python3.8"

  environment {
    variables = {
      greeting = "Hello!!!!!!"
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_log_group, aws_iam_role_policy_attachment.lambda_logs]
}