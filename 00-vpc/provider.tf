terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

   backend "s3" {
    bucket = "roboshop-dev-remote-vpc"
    key = "roboshop-dev-vpc"
    region = "us-east-1"
    encrypt = true
    use_lockfile = false  
    
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
 