resource "aws_lb_target_group_attachment" "app_1" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "app_2" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app_2.id
  port             = 80
}