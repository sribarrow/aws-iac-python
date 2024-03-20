#Creating API Gateway for the REST API

resource "aws_api_gateway_rest_api" "FileUploderService" {
  name = "FileUploderService"
}

resource "aws_api_gateway_resource" "FileUploderService" {
  parent_id   = aws_api_gateway_rest_api.FileUploderService.root_resource_id
  path_part   = "upload"
  rest_api_id = aws_api_gateway_rest_api.FileUploderService.id
}

resource "aws_api_gateway_method" "FileUploderService" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.FileUploderService.id
  rest_api_id   = aws_api_gateway_rest_api.FileUploderService.id
}

resource "aws_api_gateway_integration" "FileUploderService" {
  http_method = aws_api_gateway_method.FileUploderService.http_method
  resource_id = aws_api_gateway_resource.FileUploderService.id
  rest_api_id = aws_api_gateway_rest_api.FileUploderService.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.file_uploader_lambda.invoke_arn
}

# Method Response and Enabling CORS

resource "aws_api_gateway_method_response" "FileUploderService" {
  rest_api_id = aws_api_gateway_rest_api.FileUploderService.id
  resource_id = aws_api_gateway_resource.FileUploderService.id
  http_method = aws_api_gateway_method.FileUploderService.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true
  }

}

resource "aws_api_gateway_deployment" "FileUploderService" {
  rest_api_id = aws_api_gateway_rest_api.FileUploderService.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.FileUploderService.id,
      aws_api_gateway_method.FileUploderService.id,
      aws_api_gateway_integration.FileUploderService.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.FileUploderService.id
  rest_api_id   = aws_api_gateway_rest_api.FileUploderService.id
  stage_name    = "prod"
}

# Permission for API Gateway to invoke lambda function
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_uploader_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.FileUploderService.id}/*/${aws_api_gateway_method.FileUploderService.http_method}${aws_api_gateway_resource.FileUploderService.path}"
}