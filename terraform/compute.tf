data "archive_file" "static_content_distribution_authorizer_code" {
  type        = "zip"
  source_file = "authorizer.js"
  output_path = "lambda_deploy_package.zip"
}

data "aws_iam_policy_document" "assume_role_policy_lambda" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "service_role_lambda" {
  provider = aws.edge_region
  name     = "service_role_lambda"
  tags = {
    owner = var.resource_owner_email
  }
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_lambda.json
}

resource "aws_iam_role_policy_attachment" "sto-readonly-role-policy-attach" {
  provider   = aws.edge_region
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.service_role_lambda.name
}

resource "aws_lambda_function" "static_content_distribution_authorizer" {
  provider         = aws.edge_region
  runtime          = "nodejs12.x"
  filename         = "lambda_deploy_package.zip"
  source_code_hash = data.archive_file.static_content_distribution_authorizer_code.output_base64sha256
  function_name    = "static_content_distribution_authorizer"
  handler          = "authorizer.handler"
  tags = {
    owner = var.resource_owner_email
  }
  role    = aws_iam_role.service_role_lambda.arn
  publish = true
}

resource "aws_lambda_permission" "cloudwatch_trigger" {
  provider      = aws.edge_region
  statement_id  = "AllowExecutionFromCloudWatch"
  principal     = "events.amazonaws.com"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.static_content_distribution_authorizer.function_name
}

provider "aws" {
  alias  = "edge_region"
  region = "us-east-1"
}
