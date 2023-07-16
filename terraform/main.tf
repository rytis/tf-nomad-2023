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

module "nomad_control_plane" {
  source = "./modules/nomad_control_plane"

  ami_name = var.nomad_server_ami_name
  subnets = module.vpc.public_subnets
  security_groups = [
    module.nomad_security_group.security_group_id,
    module.ssh_security_group.security_group_id
  ]
  tags = var.nomad_server_tags
  autojoin_string = var.nomad_cloud_autojoin_string

  ssh_key_name = module.ssh_key.key_name
}

# module "nomad_worker_pool" {
#   source = "./module/nomad_worker_pool"
# }
