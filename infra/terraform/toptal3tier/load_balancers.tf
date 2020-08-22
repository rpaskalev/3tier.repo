# load_balancers.tf

resource "random_id" "target_group_sufix" {
  byte_length = 2
}

# ---------------------------------------------------------------------------------------------------------------------
# API LOAD BALANCER DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb_target_group" "api" {
  name     = "api-${var.environment}-${random_id.target_group_sufix.hex}"
  port     = "3000"
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path = "/api/status"
    matcher = "200"
    interval = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 6
  }

  tags = {
    Name        = "api-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_alb" "api" {
  name            = "api-${var.environment}"
  subnets         = ["${aws_subnet.frontend1.id}", "${aws_subnet.frontend2.id}"]
  security_groups = ["${aws_security_group.api_inbound.id}"]

  tags = {
    Name        = "api-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_alb_listener" "api_http" {
  load_balancer_arn = aws_alb.api.arn
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.api]

  default_action {
    target_group_arn = aws_alb_target_group.api.arn
    type             = "forward"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# WEB LOAD BALANCER DEFINITION
# ---------------------------------------------------------------------------------------------------------------------


resource "aws_alb_target_group" "web" {
  name     = "web-${var.environment}-${random_id.target_group_sufix.hex}"
  port     = "3000"
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path = "/"
    matcher = "200"
    interval = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 6
  }

  tags = {
    Name        = "web-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_alb" "web" {
  name            = "web-${var.environment}"
  subnets         = ["${aws_subnet.frontend1.id}", "${aws_subnet.frontend2.id}"]
  security_groups = ["${aws_security_group.web_inbound.id}"]

  tags = {
    Name        = "web-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_alb_listener" "web_http" {
  load_balancer_arn = aws_alb.web.arn
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.web]

  default_action {
    target_group_arn = aws_alb_target_group.web.arn
    type             = "forward"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CDN FOR IMAGES RULE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb_listener_rule" "image_cdn" {
  listener_arn = aws_alb_listener.web_http.arn
  priority     = 100

  action {
    type             = "redirect"

    redirect {
      host        = aws_cloudfront_distribution.web_distribution.domain_name
      path        = "/#{path}"
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/images/*"]
    }
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# CDN FOR CSS RULE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb_listener_rule" "css_cdn" {
  listener_arn = aws_alb_listener.web_http.arn
  priority     = 101

  action {
    type             = "redirect"

    redirect {
      host        = aws_cloudfront_distribution.web_distribution.domain_name
      path        = "/#{path}"
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/stylesheets/*"]
    }
  }

}