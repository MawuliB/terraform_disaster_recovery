provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "./modules/vpc"
}
