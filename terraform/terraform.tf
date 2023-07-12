terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.7"
    }
  }

  backend "s3" {
    bucket = "rsi-tf-nomad-2023-state"
    region = "us-east-2"
    key = "terraform.tfstate"
    dynamodb_table = "rsi-tf-nomad-2023-state"
  }
}
