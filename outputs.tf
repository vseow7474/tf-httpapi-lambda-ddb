output "invoke_url" {
  value = trimsuffix(aws_apigatewayv2_stage.default.invoke_url, "/")
}

output "aws_dynamodb_table_name" {
  value = aws_dynamodb_table.table.name
}

output "aws_cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.lambda_log_group.name
}

output "name_prefix" {
  value = data.aws_caller_identity.current.arn
}

# Output the ARN of the created Metric Filter
output "metric_filter_arn" {
  value       = aws_cloudwatch_log_metric_filter.vic_metric_filter.id
  description = "The ARN of the created metric filter."
}

# Output SNS Topic ARN
output "sns_topic_arn" {
  value = aws_sns_topic.example_topic.arn
  description = "The ARN of the SNS topic."
}