
module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "5.3.0"

  name        = var.sg_name
  description = "Security group for web servers allowing HTTP traffic"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443,
      to_port     = 443,
      protocol    = "tcp",
      cidr_blocks = var.ingress_cidr_blocks[0]
    },
    {
      from_port   = 22,
      to_port     = 22,
      protocol    = "tcp",
      cidr_blocks = var.ingress_cidr_blocks[0]
    }
  ]

  ingress_cidr_blocks = var.ingress_cidr_blocks
  egress_cidr_blocks  = var.egress_cidr_blocks

  tags = var.tags
}
