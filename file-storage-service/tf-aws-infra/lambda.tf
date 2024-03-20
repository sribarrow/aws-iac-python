#defining variables for Lambda funtcion
locals {
  lambda_src_dir    = "${path.module}/../backend/"
  lambda_function_zip_path = "${path.module}/lambda/lambda_function.zip"
}

# Creating an IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "LambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Creating S3 policy for Lambda functiion role to get and put objects to S3 bucket
data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetObject", "s3:PutObject", "s3:CopyObject", "s3:HeadObject",
                    "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "lambda-policy"
  policy      = data.aws_iam_policy_document.policy.json
}

# Attaching the policy created above to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  policy_arn = aws_iam_policy.policy.arn
  role       = aws_iam_role.lambda_role.name
}

# Creating the Lambda function using data resource
data "archive_file" "lambda" {
  source_dir  = local.lambda_src_dir
  output_path = local.lambda_function_zip_path
  type        = "zip"
}

resource "aws_lambda_function" "file_uploader_lambda" {
  filename      = local.lambda_function_zip_path 
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = 20
  memory_size   = 128
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      USER_BUCKET = var.user_bucket,
    }
  }

}