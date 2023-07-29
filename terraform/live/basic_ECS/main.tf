terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.61"
    }
  }

  required_version = ">= 1.2.7"
}

provider "aws" {
  region = "eu-central-1"
}