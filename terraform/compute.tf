resource "aws_instance" "app_1" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  key_name      = var.key_name

  subnet_id = aws_subnet.public_1a.id

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]
  iam_instance_profile        = aws_iam_instance_profile.ec2_cloudwatch.name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/user_data.sh")
  tags = {
    Name = "urlshortener-app"
  }
}

resource "aws_instance" "app_2" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  key_name      = var.key_name

  subnet_id = aws_subnet.public_1b.id

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]
  iam_instance_profile        = aws_iam_instance_profile.ec2_cloudwatch.name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/user_data.sh")
  tags = {
    Name = "urlshortener-app-2"
  }
}
