terraform {
  backend "s3" {
    bucket         = "tf-state-2026"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}