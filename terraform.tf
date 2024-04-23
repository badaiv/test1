terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.46.0"
    }
  }

  required_version = ">= 1.8.0"

#  backend "s3" {
#    bucket = "terraform-backend"
#    key    = "staging"
#    region = "us-east-1"
#    dynamodb_table = "TerraformLock"
#  }
}
