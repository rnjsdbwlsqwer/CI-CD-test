terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "yujin" {
  region = "ap-northeast-2"
}

resource "aws_s3_bucket" "example" {
  bucket        = "yujin-bucket"
  force_destroy = true
}

resource "random_id" "suffix" {
  byte_length = 4
}
