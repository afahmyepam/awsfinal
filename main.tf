terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.10.0"
    }
  }
}


provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Staging-Education"
      Project = "ghost-cloudx"
      Scope       = "final-task"
    }
  }
}
