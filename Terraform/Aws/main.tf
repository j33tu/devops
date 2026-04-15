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

module "s3bucket" {
  source             = "./modules/s3-bucket"
  bucket_name_prefix = "stage"
  location           = "ap-south-1"
  s3bucketname       = "g2s3bucket"
}
module "s3bucket1" {
  source             = "./modules/s3-bucket"
  bucket_name_prefix = "prod"
  location           = "ap-south-1"
  s3bucketname       = "g2s3bucket1"
}


