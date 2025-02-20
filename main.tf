# This is the main file where we are calling the modules

# Modules

# VPC module
module "vpc_primary" {
  providers = {
    aws = aws.primary
  }
  source = "./modules/vpc"
  vpc_name = "dr-vpc-primary"
  vpc_cidr = "10.0.0.0/16"
  availability_zones = ["eu-west-1a", "eu-west-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  tags = {
    "Name": "dr-vpc-primary"
  }
}

module "vpc_secondary" {
  providers = {
    aws = aws.secondary
  }
  source = "./modules/vpc"
  vpc_name = "dr-vpc-secondary"
  vpc_cidr = "10.0.0.0/16"
  availability_zones = ["eu-west-2a", "eu-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  tags = {
    "Name": "dr-vpc-secondary"
  }
}

# Security group module

module "security_group" {
  providers = {
    aws = aws.primary
  }
  source = "./modules/security_group"
  sg_name = "dr_sg_primary"
  vpc_id = module.vpc_primary.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  tags = {
    "Name": "dr_sg"
  }
}

module "security_group_secondary" {
  providers = {
    aws = aws.secondary
  }
  source = "./modules/security_group"
  sg_name = "dr_sg_secondary"
  vpc_id = module.vpc_secondary.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  tags = {
    "Name": "dr_sg"
  }
}