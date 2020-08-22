# logs.tf

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP AND STREAM SETUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "toptal3tier_log_group" {
  name              = "toptal3tier_log_group"
  retention_in_days = 30

  tags = {
    Name = "toptal3tier-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "toptal3tier_log_stream" {
  name           = "toptal3tier_log_stream"
  log_group_name = aws_cloudwatch_log_group.toptal3tier_log_group.name
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH DASHBOARD SETUP
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "dashboard" {
  template = file("./templates/cloudwatch/dashboard.json.tpl")

  vars = {
    api_target_group    = aws_alb_target_group.api.arn_suffix
    api_load_balancer   = aws_alb.api.arn_suffix
    web_target_group    = aws_alb_target_group.web.arn_suffix
    web_load_balancer   = aws_alb.web.arn_suffix
    api_service         = aws_ecs_service.api.name
    api_cluster         = aws_ecs_cluster.api.name
    web_service         = aws_ecs_service.web.name
    web_cluster         = aws_ecs_cluster.web.name
    database_identifier = aws_db_instance.main.identifier
    region              = var.region
  }
}

resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  dashboard_name = "${var.application}-${var.environment}"
  dashboard_body = data.template_file.dashboard.rendered
}