
variable "elastic_ip_allocation_id" {
  type = string
  description = "Allocation ID of an Elastic IP to attach to the webserver"
}


// Network

resource "aws_vpc" "vpc_poca" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_poca" {
  vpc_id = aws_vpc.vpc_poca.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id = aws_instance.ec2_poca.id
  allocation_id = var.elastic_ip_allocation_id
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
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
