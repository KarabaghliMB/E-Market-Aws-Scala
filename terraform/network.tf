
resource "aws_vpc" "vpc_poca" {
  cidr_block = "10.0.0.0/16"
}

// Network for internet-facing resources

resource "aws_subnet" "subnet_front" {
  vpc_id = aws_vpc.vpc_poca.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_internet_gateway" "gw_poca" {
  vpc_id = aws_vpc.vpc_poca.id
}

resource "aws_default_route_table" "rt_front" {
  default_route_table_id = aws_vpc.vpc_poca.default_route_table_id
}

resource "aws_route" "route_front_internet" {
  route_table_id = aws_default_route_table.rt_front.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw_poca.id
}

variable "elastic_ip_allocation_id" {
  type = string
  description = "Allocation ID of an Elastic IP to attach to the webserver"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id = aws_instance.ec2_poca.id
  allocation_id = var.elastic_ip_allocation_id
}


// Network for the database

resource "aws_subnet" "subnet_back_a" {
  vpc_id = aws_vpc.vpc_poca.id
  cidr_block = "10.0.128.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "subnet_back_b" {
  vpc_id = aws_vpc.vpc_poca.id
  cidr_block = "10.0.129.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

data "aws_availability_zones" "available" {
  state = "available"
}


// Security groups

resource "aws_security_group" "sg_front" {
  name = "secgroup-front"
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

resource "aws_security_group" "sg_back" {
  name = "secgroup-back"
  vpc_id = aws_vpc.vpc_poca.id

  ingress {
    description = "HTTP requests from clients"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.sg_front.id]
  }
}
