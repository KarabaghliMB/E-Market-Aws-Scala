
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.7.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"  # Europe (Paris)
  access_key = "AKIASU7PHFLFJM76F5UX"
  secret_key = "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"
}

data "aws_ami" "amazon_linux_2" {
 most_recent = true
 owners = ["amazon"]

 filter {
   name = "name"
   values = ["amzn2-ami-hvm-*-x86_64-gp2"]
 }
}

resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
}
