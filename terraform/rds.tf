
variable "db_password" {
  type = string
  description = "Password of the database master user"
}

resource "aws_db_instance" "db_poca" {
  allocated_storage = 20
  db_subnet_group_name = aws_db_subnet_group.dbsubnet_poca.name
  engine = "postgres"
  engine_version = "12.4"
  instance_class = "db.t2.micro"
  skip_final_snapshot = true

  name = "poca"
  username = "poca"
  password = var.db_password
  port = 5432

  storage_type = "gp2"
  vpc_security_group_ids = [aws_security_group.sg_back.id]
}

resource "aws_db_subnet_group" "dbsubnet_poca" {
  name = "dbsubnet-poca"
  subnet_ids = [aws_subnet.subnet_back_a.id, aws_subnet.subnet_back_b.id]
}

resource "aws_ssm_parameter" "db_password" {
  name = "/database/password"
  type = "SecureString"
  value = var.db_password
}

output "db_ip" {
  value = aws_db_instance.db_poca.address
  description = "IP address of the database"
}
