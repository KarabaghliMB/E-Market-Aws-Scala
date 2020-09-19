/*
The AWS user used by terraform is granted the following policy:

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:StartInstances",
                "ec2:TerminateInstances",
                "ec2:StopInstances",
                "ec2:MonitorInstances",
                "ec2:ModifyInstanceAttribute",
                "ec2:UnmonitorInstances"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ec2:RunInstances",
            "Resource": [
                "arn:aws:ec2:eu-west-3:182500928202:instance/*"
            ],
            "Condition": {
                "StringEquals": {
                    "ec2:InstanceType": [
                        "t2.micro"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "ec2:RunInstances",
            "Resource": [
                "arn:aws:ec2:eu-west-3::image/*",
                "arn:aws:ec2:eu-west-3:182500928202:subnet/*",
                "arn:aws:ec2:eu-west-3:182500928202:network-interface/*",
                "arn:aws:ec2:eu-west-3:182500928202:volume/*",
                "arn:aws:ec2:eu-west-3:182500928202:key-pair/*",
                "arn:aws:ec2:eu-west-3:182500928202:security-group/*"
            ]
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "sts:DecodeAuthorizationMessage"
            ],
            "Resource": "*"
        }
    ]
}
*/

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
