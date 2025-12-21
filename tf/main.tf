terraform {
  backend "s3" {
    bucket         = "cka-or-die-trying-tfstate-6969696969"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "cka-or-die-trying-tfstate-lock"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}
