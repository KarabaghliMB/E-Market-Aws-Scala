
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
resource "aws_cloudwatch_log_group" "poca_web" {
  name = "poca-web"
  retention_in_days = 30
}
