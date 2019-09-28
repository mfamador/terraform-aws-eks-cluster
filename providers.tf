provider "aws" {
  version = "~> 2.7"
  region = var.region
  profile = var.aws_profile
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

