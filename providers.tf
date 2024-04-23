provider "aws" {
  region = "us-east-1"
  profile = "account0"
}

provider "aws" {
  alias  = "account-1"
  region = "us-east-1"
  profile = "account1"
}
