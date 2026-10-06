resource "aws_ecr_repository" "app" {
  name = "urlshortener"
  force_delete = true
  
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "urlshortener"
  }
}