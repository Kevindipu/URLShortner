resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "urlshortener-vpc"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "urlshortener-public-1a"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1b"

  tags = {
    Name = "urlshortener-public-1b"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "urlshortener-private-1a"
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-north-1b"

  tags = {
    Name = "urlshortener-private-1b"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "urlshortener-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "urlshortener-public-rt"
  }
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "urlshortener-private-rt"
  }
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_1b" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "alb" {
  name        = "urlshortener-alb-sg"
  description = "Allow HTTP traffic to the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "urlshortener-alb-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "urlshortener-app-sg"
  description = "Allow traffic to application servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "urlshortener-app-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "urlshortener-db-sg"
  description = "Allow PostgreSQL from application servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from app servers"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "urlshortener-db-sg"
  }
}

resource "aws_db_subnet_group" "main" {
  name = "urlshortener-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1b.id
  ]

  tags = {
    Name = "urlshortener-db-subnet-group"
  }
}

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
  user_data = file("${path.module}/user_data.sh")
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
  user_data = file("${path.module}/user_data.sh")
  tags = {
    Name = "urlshortener-app-2"
  }
}