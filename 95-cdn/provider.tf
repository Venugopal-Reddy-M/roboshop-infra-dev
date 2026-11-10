terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

   backend "s3" {
    bucket = "roboshop-dev-remote-vpc" # bucket for aws remote state
    # key store inside the bucket
    key = "roboshop-dev-cdn"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
    
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
 
 