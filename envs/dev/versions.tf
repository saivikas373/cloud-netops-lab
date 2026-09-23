terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "lab"


  default_tags {
    tags = {
      project    = "cloud-netops-lab"
      env        = "dev"
      managed_by = "terraform"
    }
  }
}