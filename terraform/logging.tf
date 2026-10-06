resource "aws_cloudwatch_log_group" "app" {
  name              = "/urlshortener/app"
  retention_in_days = 7

  tags = {
    Name = "urlshortener-app-logs"
  }
}