/*
The AWS user used by terraform is granted the following policy:

{
    "Version": "2012-10-17",
    "Statement": [
        {
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
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::poca-tfstates"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::poca-tfstates/poca-2020"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem"
            ],
            "Resource": "arn:aws:dynamodb:eu-west-3:182500928202:table/poca-tfstates-locks"
        },
        {
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
  backend "s3" {
    bucket = "poca-tfstates"
    key = "poca-2020"
    region = "eu-west-3"
    dynamodb_table = "poca-tfstates-locks"
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


// EC2 Instance

resource "aws_instance" "ec2_poca" {
  ami = data.aws_ssm_parameter.ecs_ami.value
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_poca.id]
  subnet_id = aws_subnet.subnet_poca.id
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name

  user_data = <<EOF
#!/bin/bash
# The cluster this agent should check into.
echo 'ECS_CLUSTER=${aws_ecs_cluster.cluster_poca.name}' >> /etc/ecs/ecs.config
# Disable privileged containers.
echo 'ECS_DISABLE_PRIVILEGED=true' >> /etc/ecs/ecs.config
EOF

  // Uncomment to allow ssh connection using the key named "debug"
  //key_name = "debug"
}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}


// Cluster

resource "aws_ecs_cluster" "cluster_poca" {
  name = "cluster-poca"
}


// Instance role
// This gives the required permissions to the ECS daemon on the EC2 instance
// See https://github.com/trussworks/terraform-aws-ecs-cluster/blob/master/main.tf

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  path = "/"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs_instance_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_instance_assume_role_policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attachment" {
    role = aws_iam_role.ecs_instance_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


// Network

resource "aws_vpc" "vpc_poca" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_poca" {
  vpc_id = aws_vpc.vpc_poca.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_eip" "eip_poca" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id = aws_instance.ec2_poca.id
  allocation_id = aws_eip.eip_poca.id
}

resource "aws_internet_gateway" "gw_poca" {
  vpc_id = aws_vpc.vpc_poca.id
}

resource "aws_default_route_table" "rt_poca" {
  default_route_table_id = aws_vpc.vpc_poca.default_route_table_id
}

resource "aws_route" "route_poca_internet" {
  route_table_id = aws_default_route_table.rt_poca.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw_poca.id
}


// Security group

resource "aws_security_group" "sg_poca" {
  name = "secgroup-poca"
  vpc_id = aws_vpc.vpc_poca.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP requests from clients"
    from_port = 22 // TODO: remove
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


// Task definition

resource "aws_ecs_task_definition" "td_poca" {
  family = "td_poca"
  container_definitions = file("task_definition_poca.json")

  // IAM role of the Docker container
  // This is needed for the app to make calls to AWS services (an AWS database for example)
  //task_role_arn = ...

  // Task execution role of the ECS daemon
  // This is needed to fetch secrets or log to Cloudwatch for example
  // See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
  //execution_role = ...

  network_mode = "bridge"
}


// Service

resource "aws_ecs_service" "service_poca" {
  name = "service-poca"
  cluster = aws_ecs_cluster.cluster_poca.id
  deployment_controller {
    type = "ECS"
  }
  force_new_deployment = true
  scheduling_strategy = "DAEMON"
  task_definition = aws_ecs_task_definition.td_poca.arn
}


// Log group
// ...
