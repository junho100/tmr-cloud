################################################################################
# EC2 Module
################################################################################
module "backend" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = format(module.naming.result, "backend-ec2")

  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = "t2.micro"
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.sg_for_bastion_host.security_group_id]
  associate_public_ip_address = true

  key_name = aws_key_pair.key_pair_for_backend.key_name

  iam_instance_profile = module.backend_instance_role.iam_instance_profile_name

  user_data = file("./files/user-data.sh")
}

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

################################################################################
# Supporting Resources
################################################################################
resource "tls_private_key" "private_key_for_backend" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair_for_backend" {
  key_name   = format(module.naming.result, "backend-key")
  public_key = tls_private_key.private_key_for_backend.public_key_openssh
}

resource "local_file" "backend_ssh_key" {
  filename = "${path.module}/${aws_key_pair.key_pair_for_backend.key_name}.pem"
  content  = tls_private_key.private_key_for_backend.private_key_pem
}
