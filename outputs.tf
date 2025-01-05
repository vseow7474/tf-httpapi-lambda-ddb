output "invoke_url" {
  value = trimsuffix(aws_apigatewayv2_stage.default.invoke_url, "/")
}

output "aws_dynamodb_table_name" {
  value = aws_dynamodb_table.table.name
}

output "aws_cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.lambda_log_group.name
}