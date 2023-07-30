terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.7"
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2.4"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "rsi-tf-nomad-2023-state"
    region = "us-east-2"
    key = "terraform.tfstate"
    dynamodb_table = "rsi-tf-nomad-2023-state"
  }
}
