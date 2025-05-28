provider "aws" {
  region = "ap-northeast-2"
}

# GitHub OIDC 공급자 생성
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

# GitHub Actions에서 AssumeRole할 수 있는 IAM Role 생성
resource "aws_iam_role" "github_oidc_role" {
  name = "github-actions-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub" = "repo:rnjsdbwlsqwer/CI-CD-test:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_oidc_attach" {
  role       = aws_iam_role.github_oidc_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# EC2 인스턴스
resource "aws_instance" "web_server" {
  ami           = "ami-0c9c942bd7bf113a2"
  instance_type = "t2.micro"

  tags = {
    Name = "web-server-2"
  }
}

# S3 버킷 
resource "aws_s3_bucket" "artifact" {
  bucket = "tiltil-2-artifact-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# IAM Role 
resource "aws_iam_role" "codedeploy_role" {
  name = "yujin3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Role에 정책 연결
resource "aws_iam_role_policy_attachment" "codedeploy_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# CodeDeploy App 
resource "aws_codedeploy_app" "my_app" {
  name              = "yujin3"
  compute_platform  = "Server"
}

# CodeDeploy 배포 그룹
resource "aws_codedeploy_deployment_group" "my_group" {
  app_name               = aws_codedeploy_app.my_app.name
  deployment_group_name  = "yujin3-group"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
}
