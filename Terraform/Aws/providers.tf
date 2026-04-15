terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "ap-south-2"
}
terraform {
  backend "s3" {
    bucket = "g2terraformbucket"
    key    = "awsinfra/terraform.tfstate"
    region = "ap-south-2"
  }
}
