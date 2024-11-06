terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "ap-northeast-2"
}

provider "aws" {
  alias      = "cheego"
  access_key = var.cheego_aws_access_key
  secret_key = var.cheego_aws_secret_key
  region     = "ap-northeast-2"
}
