# This is the main file where we are calling the modules

# Modules

# VPC module
module "vpc_primary" {
  providers = {
    aws = aws.primary
  }
  source             = "./modules/vpc"
  vpc_name           = "dr-vpc-primary"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-west-1a", "eu-west-1b"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  tags = {
    "Name" : "dr-vpc-primary"
  }
}

module "vpc_secondary" {
  providers = {
    aws = aws.secondary
  }
  source             = "./modules/vpc"
  vpc_name           = "dr-vpc-secondary"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-west-2a", "eu-west-2b"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  tags = {
    "Name" : "dr-vpc-secondary"
  }
}

# Security group module

module "security_group_primary" {
  providers = {
    aws = aws.primary
  }
  source              = "./modules/security_group"
  sg_name             = "dr_sg_primary"
  vpc_id              = module.vpc_primary.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  tags = {
    "Name" : "dr_sg"
  }
}

module "security_group_secondary" {
  providers = {
    aws = aws.secondary
  }
  source              = "./modules/security_group"
  sg_name             = "dr_sg_secondary"
  vpc_id              = module.vpc_secondary.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  tags = {
    "Name" : "dr_sg"
  }
}

# EC2 module

module "ec2" { # This is a stopped EC2 instance for that would serve as immediate backup in the secondary region
  providers = {
    aws = aws.secondary
  }
  source        = "./modules/ec2"
  ami_id        = var.ami_id_secondary
  instance_type = "t3.micro"
  subnet_id     = module.vpc_secondary.public_subnets[0]
  vpc_id        = module.vpc_secondary.vpc_id
  sg_id         = module.security_group_secondary.security_group_id
  instance_name = "dr-ec2"
  region        = var.aws_region_secondary
}

# ASG module

module "asg_primary" {
  depends_on = [module.elb_primary]
  providers = {
    aws = aws.primary
  }
  source               = "./modules/asg"
  ami_id               = var.ami_id_primary
  instance_type        = "t3.micro"
  security_group_id    = module.security_group_primary.security_group_id
  subnet_ids           = module.vpc_primary.public_subnets
  desired_capacity     = 1
  min_size             = 1
  max_size             = 2
  alb_target_group_arn = module.elb_primary.alb_target_group_arn
}

module "asg_secondary" {
  depends_on = [module.elb_secondary]
  providers = {
    aws = aws.secondary
  }
  source               = "./modules/asg"
  ami_id               = var.ami_id_secondary
  instance_type        = "t3.micro"
  security_group_id    = module.security_group_secondary.security_group_id
  subnet_ids           = module.vpc_secondary.public_subnets
  desired_capacity     = 0
  min_size             = 0
  max_size             = 0
  alb_target_group_arn = module.elb_secondary.alb_target_group_arn
}

# ELB module

module "elb_primary" {
  providers = {
    aws = aws.primary
  }
  elb_name   = "webserver-elb-primary"
  source     = "./modules/elb"
  vpc_id     = module.vpc_primary.vpc_id
  subnet_ids = [module.vpc_primary.public_subnets[0], module.vpc_primary.public_subnets[1]]
  sg_id      = module.security_group_primary.security_group_id
}

module "elb_secondary" {
  providers = {
    aws = aws.secondary
  }
  elb_name   = "webserver-elb-secondary"
  source     = "./modules/elb"
  vpc_id     = module.vpc_secondary.vpc_id
  subnet_ids = [module.vpc_secondary.public_subnets[0], module.vpc_secondary.public_subnets[1]]
  sg_id      = module.security_group_secondary.security_group_id

}