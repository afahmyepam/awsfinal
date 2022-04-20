# 6 - Create IAM role 

# Create IAM Role and asosiated IAM Role profile (name=ghost_app) with the following permissions:
# "ec2:Describe*",
# "ecr:GetAuthorizationToken",
# "ecr:BatchCheckLayerAvailability",
# "ecr:GetDownloadUrlForLayer",
# "ecr:BatchGetImage",
# "logs:CreateLogStream",
# "logs:PutLogEvents",
# "ssm:GetParameter*",
# "secretsmanager:GetSecretValue",
# "kms:Decrypt"
# "elasticfilesystem:DescribeFileSystems",
# "elasticfilesystem:ClientMount",
# "elasticfilesystem:ClientWrite"
# This IAM role provides EC2 and Fargate instances with access to the services.
# For test purposes it acceptable to allow "any" resource access. 
# You would consider to restrict each service in policy with resource arn(using separate statement for each service) in the real environments.


resource "aws_iam_role" "ghost_app" {
  name = "ghost_app"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "*"
        }
      },
    ]
  })

  tags = {
    tag-key = "ghost_app"
  }
}
resource "aws_iam_policy" "ghost_app" {
  name        = "ghost_app-policy"
  description = "A ghost_app policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "rds:DescribeDBInstances",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ssm:GetParameter*",
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt",
        "elasticfilesystem:Describe*",
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ghost_app" {
  role       = aws_iam_role.ghost_app.name
  policy_arn = aws_iam_policy.ghost_app.arn
}