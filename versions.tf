terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.iam_role_to_assume
  }
}


module "provider_versions" {
  source = "git::https://github.com/GlueOps/terraform-module-provider-versions.git?ref=feat-update-aws-provider"
}

