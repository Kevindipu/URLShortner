resource "aws_ecr_repository" "app" {
  name = "urlshortener"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "urlshortener"
  }
}