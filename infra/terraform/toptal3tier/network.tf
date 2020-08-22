# network.tf

# ---------------------------------------------------------------------------------------------------------------------
# MAIN VPC DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr_prefix}.${var.vpc_cidr_suffix}"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.application}-${var.environment}"
    Environment = "${var.environment}"
  }
  lifecycle { create_before_destroy = true }
}

# ---------------------------------------------------------------------------------------------------------------------
# BACKEND SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "db_primary" {
  vpc_id = aws_vpc.main.id
  availability_zone = "us-west-2a"
  cidr_block = "${var.vpc_cidr_prefix}.20.0/24"
  map_public_ip_on_launch = false
  depends_on = [aws_internet_gateway.main]
  tags = {
    Name = "primaryDB-${var.application}-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "db_secondary" {
  vpc_id = aws_vpc.main.id
  availability_zone = "us-west-2b"
  cidr_block = "${var.vpc_cidr_prefix}.30.0/24"
  map_public_ip_on_launch = false
  depends_on = [aws_internet_gateway.main]
  tags = {
    Name = "secondaryDB-${var.application}-${var.environment}"
    Environment = "${var.environment}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# FRONTEND SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "frontend1" {
  vpc_id = aws_vpc.main.id
  availability_zone = "us-west-2c"
  cidr_block = "${var.vpc_cidr_prefix}.33.0/24"
  map_public_ip_on_launch = true
  depends_on = [aws_internet_gateway.main]
  tags = {
    Name = "frontend1-${var.application}-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "frontend2" {
  vpc_id = aws_vpc.main.id
  availability_zone = "us-west-2d"
  cidr_block = "${var.vpc_cidr_prefix}.32.0/24"
  map_public_ip_on_launch = true
  depends_on = [aws_internet_gateway.main]
  tags = {
    Name = "frontend2-${var.application}-${var.environment}"
    Environment = "${var.environment}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GATEWAY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags =  {
    Name = "${var.application}-${var.environment}"
    Environment = "${var.environment}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# BACKEND ROUTING
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "db_primary" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "primaryDB-${var.application}-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "db_primary" {
  subnet_id = aws_subnet.db_primary.id
  route_table_id = aws_route_table.db_primary.id
}

resource "aws_route_table" "db_secondary" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "secondaryDB-${var.application}-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "db_secondary" {
  subnet_id = aws_subnet.db_secondary.id
  route_table_id = aws_route_table.db_secondary.id
}

# ---------------------------------------------------------------------------------------------------------------------
# FRONTEND ROUTING
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "traffic" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "traffic-${var.application}-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "traffic1" {
  subnet_id = aws_subnet.frontend1.id
  route_table_id = aws_route_table.traffic.id
}

resource "aws_route_table_association" "traffic2" {
  subnet_id = aws_subnet.frontend2.id
  route_table_id = aws_route_table.traffic.id
}