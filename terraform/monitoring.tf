resource "aws_sns_topic" "alerts" {
  name = "urlshortener-alerts"

  tags = {
    Name = "urlshortener-alerts"
  }
}

resource "aws_cloudwatch_metric_alarm" "app_1_cpu" {
  alarm_name        = "urlshortener-app-1-high-cpu"
  alarm_description = "Triggers when EC2 app 1 CPU usage is too high"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    InstanceId = aws_instance.app_1.id
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "app_2_cpu" {
  alarm_name        = "urlshortener-app-2-high-cpu"
  alarm_description = "Triggers when EC2 app 2 CPU usage is too high"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    InstanceId = aws_instance.app_2.id
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  alarm_name        = "urlshortener-alb-no-healthy-targets"
  alarm_description = "Triggers when the ALB has no healthy application targets"

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "db_cpu" {
  alarm_name        = "urlshortener-db-high-cpu"
  alarm_description = "Triggers when RDS database CPU usage is too high"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]
}