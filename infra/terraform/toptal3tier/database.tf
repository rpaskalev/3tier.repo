# database.tf

# ---------------------------------------------------------------------------------------------------------------------
# POSTGRES DB CLUSTER DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_subnet_group" "main" {
  name = var.environment
  description = "Main RDS subnet group"
  subnet_ids = [
    "${aws_subnet.db_primary.id}",
    "${aws_subnet.db_secondary.id}",
  ]

  tags = {
    Name = "${var.application}-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_db_parameter_group" "main" {
  name = var.application
  family = "postgres11"
}

resource "aws_db_instance" "main" {
  identifier = var.application
  username = var.root_db_user
  password = var.root_db_password
  name = var.db_name
  backup_retention_period = var.backup_retention_period

  instance_class = var.rds_instance_class
  engine = "postgres"
  engine_version = "11"
  parameter_group_name = aws_db_parameter_group.main.name

  storage_type = "standard"
  storage_encrypted = var.rds_encrypted
  allocated_storage = "20"

  multi_az = var.rds_multi_az
  publicly_accessible = "false"
  enabled_cloudwatch_logs_exports = ["postgresql"]

  apply_immediately = "true"
  skip_final_snapshot = "true"

  vpc_security_group_ids = [
    "${aws_security_group.db_instance.id}",
  ]

  db_subnet_group_name = aws_db_subnet_group.main.name

  tags = {
    Name = "${var.application}-${var.environment}"
    Environment = "${var.environment}"
  }
}