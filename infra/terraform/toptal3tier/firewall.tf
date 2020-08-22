# firewall.tf

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUPS FOR WEB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "web_inbound" {
  name        = "web_inbound-${var.environment}"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "web_inbound-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "web_internal" {
  vpc_id      = aws_vpc.main.id
  name        = "web_internal-${var.environment}"
  description = "WEB container access"

  tags = {
    Name        = "web_internal-${var.environment}"
    Environment = "${var.environment}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUPS FOR API
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "api_inbound" {
  name        = "api_inbound-${var.environment}"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "api_inbound-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "api_internal" {
  vpc_id      = aws_vpc.main.id
  name        = "api_internal-${var.environment}"
  description = "API container access"

  tags = {
    Name        = "api_internal-${var.environment}"
    Environment = "${var.environment}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUPS FOR DATABASE
# ---------------------------------------------------------------------------------------------------------------------


resource "aws_security_group" "db_instance" {
  name = "${var.environment}-db_instance"
  description = "Allow SQL in from API server"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.application}-${var.environment}"
    Environment = "${var.environment}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY RULES FOR WEB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "web_inbound_http_from_all" {
  security_group_id = aws_security_group.web_inbound.id
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_inbound_egress_to_web_internal" {
  security_group_id        = aws_security_group.web_inbound.id
  type                     = "egress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  source_security_group_id = aws_security_group.web_internal.id
}

resource "aws_security_group_rule" "web_internal_ingress_from_web_inbound" {
  security_group_id        = aws_security_group.web_internal.id
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  source_security_group_id = aws_security_group.web_inbound.id
}

resource "aws_security_group_rule" "web_internal_egress_to_all" {
  security_group_id        = aws_security_group.web_internal.id
  type                     = "egress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY RULES FOR API
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "api_inbound_http_from_all" {
  security_group_id = aws_security_group.api_inbound.id
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "api_inbound_egress_to_api_internal" {
  security_group_id        = aws_security_group.api_inbound.id
  type                     = "egress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  source_security_group_id = aws_security_group.api_internal.id
}

resource "aws_security_group_rule" "api_internal_ingress_from_api_inbound" {
  security_group_id        = aws_security_group.api_internal.id
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  source_security_group_id = aws_security_group.api_inbound.id
}

resource "aws_security_group_rule" "api_internal_egress_to_all" {
  security_group_id        = aws_security_group.api_internal.id
  type                     = "egress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "api_internal_egress_to_db" {
  security_group_id        = aws_security_group.api_internal.id
  type                     = "egress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db_instance.id
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY RULES FOR DATABASE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "db_ingress_from_api_internal" {
  security_group_id        = aws_security_group.db_instance.id
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.api_internal.id
}