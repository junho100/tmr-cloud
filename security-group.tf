module "sg_for_bastion_host" {
  source = "terraform-aws-modules/security-group/aws"

  name        = format(module.naming.result, "bastion-host-sg")
  description = "sg for bastion host"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "allow ssh traffic"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "allow http traffic"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "allow https traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]
}

module "sg_for_rds" {
  source = "terraform-aws-modules/security-group/aws"

  name        = format(module.naming.result, "rds-sg")
  description = "sg for rds instance"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "allow 3306 port traffic from bastion"
      source_security_group_id = module.sg_for_bastion_host.security_group_id
    }
  ]

  egress_rules = ["all-all"]
}
