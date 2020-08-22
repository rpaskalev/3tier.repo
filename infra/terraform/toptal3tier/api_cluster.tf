# api_cluster.tf

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE API ECS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_cluster" "api" {
  name = "api-cluster"
}

# ---------------------------------------------------------------------------------------------------------------------
# API TASK DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "api" {
  template = file("./templates/ecs/api.json.tpl")

  vars = {
    image        = "${var.container_registry}/${var.api_image}:${var.container_tag}"
    port         = var.api_port
    cpu          = var.fargate_cpu
    memory       = var.fargate_memory
    region       = var.region
    database_url = "postgresql://${var.root_db_user}:${var.root_db_password}@${aws_db_instance.main.address}:${var.db_port}/${var.db_name}?encoding=utf8&pool=40"
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "api-task"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.api.rendered
}

# ---------------------------------------------------------------------------------------------------------------------
# API AUTOSCALING DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_appautoscaling_target" "api_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.api.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ecs_autoscale_max_instances
  min_capacity       = var.ecs_autoscale_min_instances
}

# ---------------------------------------------------------------------------------------------------------------------
# API SERVICE DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_service" "api" {
  name            = "api-service"
  cluster         = aws_ecs_cluster.api.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.api_internal.id}"]
    subnets          = ["${aws_subnet.frontend1.id}", "${aws_subnet.frontend2.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.api.id
    container_name   = "api"
    container_port   = var.api_port
  }

  depends_on = [aws_alb_listener.api_http, aws_iam_role_policy.ecs_service_role_policy]
}