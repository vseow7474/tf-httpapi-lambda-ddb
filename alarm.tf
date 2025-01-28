# Create a CloudWatch Logs Metric Filter in an existing Log Group

resource "aws_cloudwatch_log_metric_filter" "vic_metric_filter" {
  name           = "VictorMetricFilter"
  pattern        = "[INFO]"                                       # Example pattern to match logs with status=INFO
  log_group_name = aws_cloudwatch_log_group.lambda_log_group.name # Specify your log group name
  
  provider = aws

  metric_transformation {
    name      = "Info-Count"          # Custom metric name
    namespace = "/moviedb-api/victor" # Namespace for the custom metric
    value     = "1"                   # Value to report when the filter pattern matches
    unit      = "None"
  }
}

resource "aws_cloudwatch_metric_alarm" "example_alarm" {
  alarm_name          = "LambdaInfoAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Info-Count"
  namespace           = "/moviedb-api/victor"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alarm when Lambda errors exceed 10"
  actions_enabled     = true

  alarm_actions = [aws_sns_topic.example_topic.arn]
  
    #"arn:aws:sns:us-east-1:123456789012:my-sns-topic" # Replace with your SNS topic ARN
  
  # dimensions = {
  #   FunctionName = "${local.name_prefix}-topmovies-api" # Replace with your Lambda function name
  # }
}

# Create SNS Topic
resource "aws_sns_topic" "example_topic" {
  name = "victor-sns-topic"
}

# Create SNS Topic Subscription
resource "aws_sns_topic_subscription" "example_subscription" {
  topic_arn = aws_sns_topic.example_topic.arn
  protocol  = "email" # Protocol options: email, email-json, sms, sqs, etc.
  endpoint  = "vseow7474@gmail.com" # Replace with your email address
}
# Wait for SNS subscription confirmation
resource "null_resource" "sns_subscription_confirmation" {
  depends_on = [aws_sns_topic_subscription.example_subscription]

  provisioner "local-exec" {
    command = <<EOT
    echo "Please confirm the subscription sent to vseow7474@gmail.com before proceeding."
    sleep 30  # Pause to allow manual confirmation
    EOT
  }
}