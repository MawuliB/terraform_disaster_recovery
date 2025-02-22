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


# S3 Module Call (Primary Region)
module "s3_primary" {
  providers = {
    aws = aws.primary
  }
  source                    = "./modules/s3"
  bucket_name               = var.primary_bucket_name
  expiration_days           = 30
  enable_replication        = true
  replication_role_arn      = module.s3_replication_role.replication_role_arn
  destination_bucket_arn    = module.s3_secondary.bucket_arn
  destination_storage_class = "STANDARD"
  tags = {
    Environment = "primary"
    Project     = "DR"
  }
}

# S3 Module Call (Secondary Region for DR)
module "s3_secondary" {
  providers = {
    aws = aws.secondary
  }
  source             = "./modules/s3"
  bucket_name        = var.secondary_bucket_name
  expiration_days    = 30
  enable_replication = false
  tags = {
    Environment = "secondary"
    Project     = "DR"
  }
}


# S3 Replication Role Module
module "s3_replication_role" {
  source                 = "./modules/iam_s3_replication"
  role_name              = "dr-s3-replication-role"
  source_bucket_arn      = module.s3_primary.bucket_arn
  destination_bucket_arn = module.s3_secondary.bucket_arn
}

# S3 Replication Configuration (Primary Region)
# module "s3_primary_replication" {
#   depends_on = [module.s3_replication_role]
#   providers = {
#     aws = aws.primary
#   }
#   source                    = "./modules/s3"
#   bucket_name               = var.primary_bucket_name
#   expiration_days           = 30
#   enable_replication        = true
#   replication_role_arn      = module.s3_replication_role.replication_role_arn
#   destination_bucket_arn    = module.s3_secondary.bucket_arn
#   destination_storage_class = "STANDARD"
# }

# RDS Module Call (Primary Region)
module "rds_primary" {
  providers = {
    aws = aws.primary
  }
  source                 = "./modules/rds"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  identifier             = "dr-primary-db"
  db_subnet_ids          = module.vpc_primary.private_subnets
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = var.db_parameter_group
  vpc_security_group_ids = [module.security_group_primary.security_group_id]
  multi_az               = false
  tags = {
    Environment = "primary"
    Project     = "DR"
  }
}

# RDS Read Replica Call (Secondary Region)
module "rds_read_replica" {
  depends_on = [ module.rds_primary ]
  providers = {
    aws = aws.secondary
  }
  source                 = "./modules/rds_replica"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  identifier             = "dr-read-replica"
  db_subnet_ids          = module.vpc_secondary.private_subnets
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = var.db_parameter_group
  vpc_security_group_ids = [module.security_group_secondary.security_group_id]
  multi_az               = false
  # skip_final_snapshot    = false
  # is_read_replica        = false
  # This is critical: replicate from the primary DB instance
  source_db_instance_identifier = module.rds_primary.db_instance_arn
  tags = {
    Environment = "secondary"
    Project     = "DR"
  }
}

