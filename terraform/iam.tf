resource "aws_iam_role" "ec2_cloudwatch" {
  name = "urlshortener-ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "urlshortener-ec2-cloudwatch-role"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_cloudwatch" {
  name = "urlshortener-ec2-cloudwatch-profile"
  role = aws_iam_role.ec2_cloudwatch.name
}

resource "aws_iam_user" "github_actions" {
  name = "urlshortener-github-actions"

  tags = {
    Name = "urlshortener-github-actions"
  }
}

resource "aws_iam_user_policy_attachment" "github_actions_ecr" {
  user       = aws_iam_user.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}