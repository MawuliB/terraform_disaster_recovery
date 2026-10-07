terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7"
    }
  }
}

provider "aws" {
  alias  = "primary"
  region = var.aws_region
}

provider "aws" {
  alias  = "secondary"
  region = var.aws_region_secondary
}

provider "aws" {
  alias  = "recover"
  region = var.aws_region_recover
}