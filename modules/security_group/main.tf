
module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "5.3.0"

  name        = var.sg_name
  description = "Security group for web servers allowing HTTP traffic"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.ingress_cidr_blocks
  tags                = var.tags
}
