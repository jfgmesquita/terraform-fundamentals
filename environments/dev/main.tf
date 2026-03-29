terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "web-cluster" {
  source = "../../modules/web-app-module"

  server_port    = 8080
  ami            = "ami-08f5d9f4870fa3a73"
  instance_type  = "t3.micro"
  instance_count = 3
}