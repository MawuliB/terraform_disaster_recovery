# Modules

# VPC module
module "vpc_primary" {
  providers = {
    aws = aws.primary
  }
  source             = "./modules/vpc"
  vpc_name           = "dr-vpc-primary"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
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
  availability_zones = ["${var.aws_region_secondary}a", "${var.aws_region_secondary}b"]
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
  depends_on = [module.rds_primary]
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

  # This is critical: replicate from the primary DB instance
  source_db_instance_identifier = module.rds_primary.db_instance_arn
  tags = {
    Environment = "secondary"
    Project     = "DR"
  }
}


# Route53 Failover Module
module "route53_failover" {
  depends_on = [module.elb_primary, module.elb_secondary]
  source     = "./modules/route53"

  hosted_zone_id                 = var.hosted_zone_id
  domain_name                    = var.domain_name
  primary_alb_dns                = module.elb_primary.alb_dns_name
  primary_alb_zone_id            = module.elb_primary.alb_zone_id
  secondary_alb_dns              = module.elb_secondary.alb_dns_name
  secondary_alb_zone_id          = module.elb_secondary.alb_zone_id
  primary_fqdn                   = module.elb_primary.alb_dns_name
  health_check_port              = var.health_check_port
  health_check_type              = var.health_check_type
  health_check_interval          = var.health_check_interval
  health_check_failure_threshold = var.health_check_failure_threshold
  tags = {
    Environment = "DR"
    Project     = "DR"
  }
}

# Lambda Failover Module
module "lambda_failover" {
  depends_on = [module.asg_secondary, module.elb_secondary]
  source     = "./modules/lambda"

  providers = {
    aws = aws.recover
  }

  lambda_role_name     = "dr-failover-lambda-role"
  route53_zone_arn     = "arn:aws:route53:::hostedzone/${var.hosted_zone_id}"
  lambda_function_name = "DRFailoverLambda"
  lambda_runtime       = "python3.9"
  lambda_zip_path      = "modules/lambda/code/failover.zip"

  tags = {
    Environment = "DR"
    Project     = "DR"
  }
  lambda_environment_variables = {
    PRIMARY_REGION      = var.aws_region, #
    SECONDARY_REGION    = var.aws_region_secondary, #
    ASG_NAME            = module.asg_secondary.asg_name, #
    READ_REPLICA_ID     = module.rds_read_replica.db_instance_identifier, #
    SNS_TOPIC_ARN       = module.monitoring.sns_topic_arn #
  }
}


# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  providers = {
    aws = aws.primary
  }

  sns_topic_name        = "dr-alerts-topic"
  subscription_protocol = "email"
  subscription_endpoint = var.alert_email

  asg_alarm_name          = "DR-ASG-InService-Alarm"
  asg_evaluation_periods  = 2
  asg_period              = 300
  asg_inservice_threshold = 1
  asg_name                = module.asg_primary.asg_name

  rds_alarm_name          = "DR-RDS-CPU-Alarm"
  rds_evaluation_periods  = 2
  rds_period              = 300
  rds_cpu_threshold       = 80
  rds_instance_identifier = module.rds_primary.db_instance_identifier

  s3_alarm_name         = "DR-S3-Bucket-Size-Alarm"
  s3_evaluation_periods = 1
  s3_period             = 86400
  s3_size_threshold     = 10000000000
  s3_bucket_name        = module.s3_primary.bucket_name

  tags = {
    Environment = "DR"
    Project     = "DR"
  }
}


#Trigger module
module "trigger" {
  source = "./modules/trigger"

  providers = {
    aws = aws.recover
  }

  health_check_id                 = module.route53_failover.health_check_id
  health_check_alarm_name         = "DR-Route53-Health-Check-Alarm"
  health_check_evaluation_periods = 1
  health_check_period             = 60
  health_check_threshold          = 1
  lambda_function_arn             = module.lambda_failover.failover_lambda_arn
  lambda_function_name            = module.lambda_failover.lambda_function_name
}