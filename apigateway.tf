resource "aws_apigatewayv2_api" "http_api" {
  name          = "${local.name_prefix}-topmovies-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.http_api.id

  name        = "$default"
  auto_deploy = true

  # Enable Access Logging
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_access_logs.arn
    format          = jsonencode({
      requestId       = "$context.requestId",
      requestTime     = "$context.requestTime",
      httpMethod      = "$context.httpMethod",
      resourcePath    = "$context.resourcePath",
      status          = "$context.status",
      responseLatency = "$context.responseLatency",
      integrationErrorMessage = "$context.integrationErrorMessage",
    })
  }
  # Specify the IAM role for logging
  #cloudwatch_role_arn = aws_iam_role.api_gateway_logging_role.arn
}

resource "aws_apigatewayv2_integration" "apigw_lambda" {
  api_id = aws_apigatewayv2_api.http_api.id

  integration_uri        = aws_lambda_function.http_api_lambda.invoke_arn # todo: fill with apporpriate value
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# resource "aws_apigatewayv2_route" "example" {
#   api_id    = aws_apigatewayv2_api.example.id
#   route_key = "ANY /example/{proxy+}"

#   target = "integrations/${aws_apigatewayv2_integration.example.id}"
# }

# todo: fill with apporpriate value
resource "aws_apigatewayv2_route" "get_topmovies" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /topmovies"

  target = "integrations/${aws_apigatewayv2_integration.apigw_lambda.id}"
}

# todo: fill with apporpriate value
resource "aws_apigatewayv2_route" "get_topmovies_by_year" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /topmovies/{year}"

  target = "integrations/${aws_apigatewayv2_integration.apigw_lambda.id}"
}

# todo: fill with apporpriate value
resource "aws_apigatewayv2_route" "put_topmovies" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "PUT /topmovies"

  target = "integrations/${aws_apigatewayv2_integration.apigw_lambda.id}"
}

# todo: fill with apporpriate value
resource "aws_apigatewayv2_route" "delete_topmovies_by_year" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "DELETE /topmovies/{year}"

  target = "integrations/${aws_apigatewayv2_integration.apigw_lambda.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.http_api_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# Create a CloudWatch log group for API Gateway logs
resource "aws_cloudwatch_log_group" "api_gw_access_logs" {
  name = "/aws/apigateway/${local.name_prefix}-topmovies-access-logs"
  retention_in_days = 7
}

# Create a log group policy to allow API Gateway to write logs
resource "aws_iam_role" "api_gw_logging_role" {
  name               = "${local.name_prefix}-api-gateway-logging-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach a policy to allow CloudWatch logging
resource "aws_iam_policy" "api_gw_logging_policy" {
  name        = "${local.name_prefix}-api-gateway-logging-policy"
  description = "Policy for API Gateway to write logs to CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = [
          aws_cloudwatch_log_group.api_gw_access_logs.arn,
          "${aws_cloudwatch_log_group.api_gw_access_logs.arn}:*"
        ]
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "api_gw_logging_role_attach" {
  role       = aws_iam_role.api_gw_logging_role.name
  policy_arn = aws_iam_policy.api_gw_logging_policy.arn
}
