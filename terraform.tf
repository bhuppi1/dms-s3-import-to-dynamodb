provider "aws" {
  profile = "jmcore"
  region  = "eu-west-1"
  version = ">=2.20.0" 
}

provider "template" {
  version = ">=2.1"
}

terraform {
  required_version = ">= 0.12"
}