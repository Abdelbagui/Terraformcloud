terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  # access_key = "AKIAQEIP3VX3H7KG4UGP"
  # secret_key = "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"
}

terraform { 
  cloud { 
    
    organization = "ABDELBAGUI" 

    workspaces { 
      name = "abdel_workspace" 
    } 
  } 
}
