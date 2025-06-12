module "vpc" {
  source = "cloudposse/vpc/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version                 = "2.2.0"
  ipv4_primary_cidr_block = local.vpc.cidr_block
  name                    = "captain"
}


module "subnets" {
  source = "cloudposse/dynamic-subnets/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "2.4.2"

  vpc_id                         = module.vpc.vpc_id
  igw_id                         = [module.vpc.igw_id]
  nat_gateway_enabled            = var.private_subnets_enabled
  nat_instance_enabled           = false
  name                           = "captain"
  private_subnets_enabled        = var.private_subnets_enabled
  public_subnets_enabled         = true
  availability_zones             = var.availability_zones
  max_subnet_count               = length(var.availability_zones)
  public_subnets_additional_tags = var.private_subnets_enabled ? { "kubernetes.io/role/elb" = 1 } : {}
  private_subnets_additional_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_security_group" "captain" {
  name        = "captain-sg"
  description = "captain security group"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "captain_egress_all_ipv4" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.captain.id
}

resource "aws_security_group_rule" "allow_all_within_group" {
  security_group_id = aws_security_group.captain.id

  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1" # All protocols
  source_security_group_id = aws_security_group.captain.id
}
