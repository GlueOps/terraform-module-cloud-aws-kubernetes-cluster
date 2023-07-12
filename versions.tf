terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

rovider "aws" {
  region = var.region
  assume_role {
    role_arn = var.iam_role_to_assume
  }
}
