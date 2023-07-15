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

# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners = ["amazon"]
#
#   filter {
#     name = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }

data "aws_ami" "nomad" {
  most_recent = true

  filter {
    name = "name"
    values = ["nomad-2023-07"]
  }
}

module "nomad_server" {
  source = "terraform-aws-modules/ec2-instance/aws"

  count = length(module.vpc.public_subnets)

  ami = data.aws_ami.nomad.id
  instance_type = "t2.micro"

  key_name = module.ssh_key.key_name
  subnet_id = module.vpc.public_subnets[count.index]
  vpc_security_group_ids = [
    module.nomad_security_group.security_group_id,
    module.ssh_security_group.security_group_id
  ]

  instance_tags = var.nomad_server_tags

  create_iam_instance_profile = true
  iam_role_name = "nomad-auto-cluster"
  iam_role_policies = {
    NomadClusterAutodiscovery = aws_iam_policy.nomad_cluster_auto_discovery.arn
    SSMCore = data.aws_iam_policy.aws_ssm_core.arn
    CloudWatchAgent = data.aws_iam_policy.aws_cloudwatch_agent.arn
  }
}

data "aws_iam_policy_document" "nomad_cluster_auto_discovery" {
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups"
    ]
  }
}

resource "aws_iam_policy" "nomad_cluster_auto_discovery" {
  name = "nomad-cluster-autodiscovery"
  description = "Policy to allow autodiscovery of Nomad cluster nodes"
  policy = data.aws_iam_policy_document.nomad_cluster_auto_discovery.json
}

data "aws_iam_policy" "aws_ssm_core" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "aws_cloudwatch_agent" {
  name = "CloudWatchAgentServerPolicy"
}
