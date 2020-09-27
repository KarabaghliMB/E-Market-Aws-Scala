
// EC2 Instance

resource "aws_instance" "ec2_poca" {
  ami = data.aws_ssm_parameter.ecs_ami.value
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_front.id]
  subnet_id = aws_subnet.subnet_front.id
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



// Task definition

resource "aws_ecs_task_definition" "td_poca" {
  family = "td_poca"
  container_definitions = data.template_file.ecs_template.rendered

  // IAM role of the Docker container
  // This is needed for the app to make calls to AWS services (fetch data from S3 for example)
  //task_role_arn = ...

  // Task execution role of the ECS daemon
  // This is needed to fetch secrets or log to Cloudwatch for example
  // See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  network_mode = "bridge"
}

data "template_file" "ecs_template" {
  template = file("task_definition_poca.json")

  vars = {
    DB_HOST = aws_db_instance.db_poca.address
    IMAGE_DIGEST = var.image_digest
  }
}

variable "image_digest" {
  type = string
  description = "Digest of the Docker image"
  default = ""
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "access_db_password" {
  name = "access-db-password"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": [
            "ssm:GetParameters"
        ],
        "Effect": "Allow",
        "Resource": [
                "arn:aws:ssm:eu-west-3:182500928202:parameter/database/password"     
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attach_secrets" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.access_db_password.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attach_managed_policy" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
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
resource "aws_cloudwatch_log_group" "poca_web" {
  name = "poca-web"
  retention_in_days = 30
}
