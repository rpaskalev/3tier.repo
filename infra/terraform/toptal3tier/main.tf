# main.tf

terraform {

  required_version = ">= 0.12"
  backend "s3" {
    encrypt = true
    bucket = "toptal-3tier-tf-state"
    dynamodb_table = "toptal-3tier-tf-locks"
    region = "us-west-2"
    key = "terraform/state/toptal3tier.tfstate"
  }
}

provider "aws" {
  region = var.region
}


