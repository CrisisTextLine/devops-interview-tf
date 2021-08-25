# brew update && brew install terraform
# terraform init
# ** make changes **
# terraform fmt
# terraform plan -out plan.out
# zip -r part.zip part_1.py

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = "us_staging_devops_interviewee"
  region  = "us-east-2"
}

data "aws_iam_policy" "lambda" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "cloudwatch_put_metric" {
  arn = "arn:aws:iam::092841053073:policy/cloudwatch-put-metric"
}

resource "aws_iam_role" "lambda_healthcheck" {
  name = "lambda-healthcheck"
  path = "/service-role/"
  tags = {
    created-by = "terraform"
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "metrics_role" {
  role       = aws_iam_role.lambda_healthcheck.name
  policy_arn = data.aws_iam_policy.lambda.arn
}

resource "aws_iam_role_policy_attachment" "put_metrics_role" {
  role       = aws_iam_role.lambda_healthcheck.name
  policy_arn = data.aws_iam_policy.cloudwatch_put_metric.arn
}

resource "aws_lambda_function" "healthcheck" {
  runtime       = "python3.8"
  handler       = "part_1"
  function_name = "healthcheck"
  filename      = "part.zip"
  role          = aws_iam_role.lambda_healthcheck.arn
  publish       = true
  layers        = []
  tags = {
    Name = "healthcheck"
  }
}

resource "aws_cloudwatch_event_rule" "healthcheck_cron" {
  name                = "healthcheck-schedule"
  schedule_expression = "cron(*/30 * * * ? *)"
  is_enabled          = false

  description = "run the healthcheck every 5 minutes"

  tags = {
    Name = "healthcheck"
  }
  depends_on = [
    aws_lambda_function.healthcheck,
  ]
}

resource "aws_lambda_permission" "allow_cloudwatch_invoke_healthcheck" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.healthcheck.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.healthcheck_cron.arn

  depends_on = [
    aws_lambda_function.healthcheck,
    aws_cloudwatch_event_rule.healthcheck_cron,
  ]
}
