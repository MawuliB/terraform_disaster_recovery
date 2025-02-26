aws_region            = "eu-west-1"
ami_id_primary        = "ami-03fd334507439f4d1"
ami_id_secondary      = "ami-07eef52105e8a2059"
instance_type         = "t3.micro"
db_username           = "admin"    # not to be done in production
db_password           = "password" # not to be done in production
db_parameter_group    = "default.mysql8.0"
primary_bucket_name   = "dr-backup-primary-bucket"
secondary_bucket_name = "dr-backup-secondary-bucket"

hosted_zone_id                 = "************"
domain_name                    = "dr.dev.free-sns.live"
primary_fqdn                   = "dr.dev.free-sns.live"
health_check_port              = 80
health_check_type              = "HTTP"
health_check_interval          = 30
health_check_failure_threshold = 3

alert_email = "************"