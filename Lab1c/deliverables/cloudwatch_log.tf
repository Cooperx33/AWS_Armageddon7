provider "aws" {
  region = "us-east-2"
}

resource "aws_cloudwatch_log_group" "app_logs" {
  # The name of the log group. 
  # For Lambda, this MUST follow the format: /aws/lambda/<function_name>
  name              = "/aws/my-application/logs"

  # How many days to keep logs. If omitted, logs never expire (costly!).
  # Common values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365
  retention_in_days = 15

  # Best practice: Add tags for cost tracking
  tags = {
    Environment = "production"
    Application = "my-app"
  }
}