
# Author: Jitendra  Singh
#variablel section 

# Testing map functionality
variable "instance_type" {
  type = map(any)
  default = {
    default = "t2.nano"
    dev     = "t2.micro"
    test    = "t2.small"
  }

}



# for testing lookup function with terraform workspace 
variable "env_tags" {
  default = {
    default = {
      "department" = "IT"
      "owner"      = "gps"
      "app"        = "stage"
    }
    dev = {
      "department" = "IT"
      "owner"      = "rks"
      "app"        = "dev"
    }
    test = {
      "department" = "IT"
      "owner"      = "TKS"
      "app"        = "test"
    }
    prod = {
      "department" = "IT"
      "owner"      = "JKS"
      "app"        = "prod"
    }
  }

}


# for testing map functionality 
variable "buckets" {
  type = map(object({
    bucket_name_prefix = string
    s3bucketname       = string
    location           = string
    tags               = map(string)
  }))
  default = {
    dev = {
      bucket_name_prefix = "dev"
      s3bucketname       = "g2bucketmap"
      location           = "ap-south-1"
      tags = {
        Name = "prodbucket"
      }
    }
    stage = {
      bucket_name_prefix = "stage"
      s3bucketname       = "g2bucketmap"
      location           = "ap-south-1"
      tags = {
        Name = "stagebucket"
      }
    }
    prod = {
      bucket_name_prefix = "prod"
      s3bucketname       = "g2bucketmap"
      location           = "ap-south-1"
      tags = {
        Name = "prodbucket"
      }
    }
  }
}

# resource section
# deploying s3 bucket using map and for each loop
resource "aws_s3_bucket" "multibucket" {
  for_each = var.buckets
  bucket   = join("-", [each.value.bucket_name_prefix, each.value.s3bucketname, each.value.location])
  tags = {
    "Name" = each.value.tags.Name
  }
}


# deploying s3 bucket using lookup function and terraform workspace

#resource "aws_s3_bucket" "g2bucket12" {
#  bucket = "g2buckettagg2"
#  tags   = lookup(var.env_tags, terraform.workspace, var.env_tags["default"])
#  lifecycle {
#    prevent_destroy       = true
#    create_before_destroy = true
#  }

#}


# deploying s3 bucket using module 

module "s3bucketprod" {
  source             = "./modules/s3-bucket"
  bucket_name_prefix = "prod"
  s3bucketname       = "g2bucket"
  location           = "ap-south-1"

}
module "s3bucketstage" {
  source             = "./modules/s3-bucket"
  bucket_name_prefix = "stage"
  s3bucketname       = "g2bucket"
  location           = "ap-south-1"

}

# deploy s3 bucket using map and for each loop with module 

# map having all attributes for s3 bucket creation

variable "maps3buckets" {
  type = map(object({
    bucket_name_prefix = string
    s3bucketname       = string
    location           = string
    tags               = map(string)
  }))
  default = {

    "bucket1" = {
      bucket_name_prefix = "prod"
      s3bucketname       = "mapg2prodbucket"
      location           = "ap-south-1"
      tags = {
        Name = "prodbucket"
      }
    }
    "bucket2" = {
      bucket_name_prefix = "dev"
      s3bucketname       = "mapg2devbucket"
      location           = "ap-south-1"
      tags = {
        Name = "devbucket"
      }
    }

  }
}


module "mapbucket" {
  for_each           = var.maps3buckets
  source             = "./modules/s3-bucket"
  bucket_name_prefix = each.value.bucket_name_prefix
  s3bucketname       = each.value.s3bucketname
  location           = each.value.location

}
# moved block

#moved {
# from = aws_s3_bucket.g2bucket12
#  to   = aws_s3_bucket.multibucket["movedbucket"]
#}


# terraform state mv 'aws_s3_bucket.g2bucket12' 'aws_s3_bucket.multibucket["movedbucket"]'

