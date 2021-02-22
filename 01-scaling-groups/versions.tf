terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    } 
  }
  backend "s3" {
    bucket = "terraform-g7"
    key    = "statefile"
    region = "ca-central-1"
  }
}
