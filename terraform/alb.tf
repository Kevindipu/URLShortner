resource "aws_lb" "main" {
  name               = "urlshortener-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1b.id
  ]

  tags = {
    Name = "urlshortener-alb"
  }
}