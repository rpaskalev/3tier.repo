# web_cluster.tf

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE WEB ECS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_cluster" "web" {
  name = "web-cluster"
}

# ---------------------------------------------------------------------------------------------------------------------
# WEB TASK DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "web" {
  template = file("./templates/ecs/web.json.tpl")

  vars = {
    image        = "${var.container_registry}/${var.web_image}:${var.container_tag}"
    port         = var.web_port
    cpu          = var.fargate_cpu
    memory       = var.fargate_memory
    region       = var.region
    api_url      = "http://${aws_alb.api.dns_name}"
  }
}

resource "aws_ecs_task_definition" "web" {
  family                   = "web-task"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.web.rendered
}

# ---------------------------------------------------------------------------------------------------------------------
# WEB AUTOSCALING DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_appautoscaling_target" "web_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.web.name}/${aws_ecs_service.web.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ecs_autoscale_max_instances
  min_capacity       = var.ecs_autoscale_min_instances
}

# ---------------------------------------------------------------------------------------------------------------------
# WEB SERVICE DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_service" "web" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.web.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.web_internal.id}"]
    subnets          = ["${aws_subnet.frontend1.id}", "${aws_subnet.frontend2.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.web.id
    container_name   = "web"
    container_port   = var.web_port
  }

  depends_on = [aws_alb_listener.web_http, aws_iam_role_policy.ecs_service_role_policy]
}