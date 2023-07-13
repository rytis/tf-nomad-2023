provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr
  azs = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets = var.vpc_public_subnets
  map_public_ip_on_launch = true
  enable_nat_gateway = false
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "nomad_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/nomad"
  version = "~> 5.0"

  name = "nomad-sg"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  vpc_id = module.vpc.vpc_id
}

module "ssh_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 5.0"

  name = "ssh-sg"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  vpc_id = module.vpc.vpc_id
}

module "ssh_key" {
  source = "./modules/ssh"
}

module "nomad_public" {
  source = "terraform-aws-modules/ec2-instance/aws"

  count = length(module.vpc.public_subnets)

  ami = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  key_name = module.ssh_key.key_name
  subnet_id = module.vpc.public_subnets[count.index]
  vpc_security_group_ids = [
    module.nomad_security_group.security_group_id,
    module.ssh_security_group.security_group_id
  ]
}
