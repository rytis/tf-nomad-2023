data "aws_ami" "vault" {
  most_recent = true

  filter {
    name = "name"
    values = [var.ami_name]
  }
}

module "vault_server" {
  source = "terraform-aws-modules/ec2-instance/aws"

  count = length(var.subnets)

  ami = data.aws_ami.vault.id
  instance_type = "t2.micro"

  key_name = var.ssh_key_name
  subnet_id = var.subnets[count.index]
  vpc_security_group_ids = var.security_groups

  metadata_options = {
    "instance_metadata_tags" = "enabled"
  }
  instance_tags = var.tags

  create_iam_instance_profile = true
  iam_role_name = "vault-auto-cluster"
  iam_role_policies = {
    VaultClusterAutodiscovery = aws_iam_policy.vault_cluster_auto_discovery.arn
    SSMCore = data.aws_iam_policy.aws_ssm_core.arn
    CloudWatchAgent = data.aws_iam_policy.aws_cloudwatch_agent.arn
  }

  # user_data = templatefile("../../scripts/worker-bootstrap.sh", {
  #   ansible_cloud_init_env = local.nomad_worker_bootstrap_env
  # })
}

data "aws_iam_policy_document" "vault_cluster_auto_discovery" {
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

resource "aws_iam_policy" "vault_cluster_auto_discovery" {
  name = "vault-cluster-autodiscovery"
  description = "Policy to allow autodiscovery of Vault cluster nodes"
  policy = data.aws_iam_policy_document.vault_cluster_auto_discovery.json
}

data "aws_iam_policy" "aws_ssm_core" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "aws_cloudwatch_agent" {
  name = "CloudWatchAgentServerPolicy"
}
