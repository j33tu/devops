# Ideally we should follow some best practices for terraform 
# Moduler approach so we could reuse the code 
# use worksapces or create directory structure to make sure we have diff between Stg, prod and dev seprate 
# we should use map , looks up to make sure we have less static and  hard coded values 
# we should keep our terraform state into remote lcoation using s3 or azure stroage account 
# here we can configure version using ~>  this makes sure latest version is used 
# terraform init will make sure it downloads everything locally make sure we have git ignore file and this terraform file is  added 



terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.41.0"
    }
  }
}

provider "aws" {
  region = "ap-south-2"
  # choosing south india region as it is the closest to us and also has good availability of services
}


# creating vpc 

resource "aws_default_vpc" "firstvpc" {
  tags = {
    Name       = var.vpc_name
    cidr_block = "10.1.0.0/16"
  }
}

# internet gateway 
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_default_vpc.firstvpc.id

  tags = {
    department  = "IT"
    environment = "production"
    contact     = "it@company.com"
  }
}
# attaching gw to vpc 
resource "aws_internet_gateway_attachment" "example" {
  internet_gateway_id = aws_internet_gateway.gw.id
  vpc_id              = aws_default_vpc.firstvpc.id
}


# Creating two subnets in different availability zones

resource "aws_subnet" "mainsubnet" {
  vpc_id     = aws_default_vpc.firstvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
    type = "public"
  }
}

resource "aws_subnet" "secondarysubnet" {
  vpc_id     = aws_default_vpc.firstvpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Secondary"
    type = "public"
  }
}
# Create an auto scaling group 
resource "aws_launch_template" "foobar" {
  name_prefix   = "foobar"
  image_id      = "ami-1a2b3c"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "bar" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.foobar.id
    version = "$Latest"
  }
}
# Crete a web server instance
# has a lot of resources and dependencies  would love to discuss during interview 


# change defualt port 80 to 8080 



# Create load balancer and point web server to it 


resource "aws_lb" "NLB" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.public : secondarysubnet.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}


# open security group port 80 


#Create IAM user and provide restart web server 
#using moduler approach to create a user 
# restart policy 

resource "aws_iam_policy" "restart_policy" {
  name        = "restart_policy"
  description = "Policy to allow restarting web server"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:RebootInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# create user and assign policy 
module "Username1" {
  source   = "./modules/user"
  username = "user1"
}
resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = module.Username1.user_name
  policy_arn = aws_iam_policy.restart_policy.arn
}

# This could be deployed via a CICD work flow 
# We should create three tasks 
# terraform will validate
#terraform will plan and output artifact as plan.tf file
# terraform will apply the plan.tf file and deploy the infrastructure
# i could show this flow around in my home lab during interview if required 


# i was not aware about if i can use open internet to research resources to get all the terraform instances runinng 
# there are few resources which i have deployed using terraform and i am sure if  i have some right resources on internet  part of job 
# More experience towards azure but achivable in aws as well 
