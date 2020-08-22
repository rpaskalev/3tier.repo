# autoscaling.tf

# ---------------------------------------------------------------------------------------------------------------------
# API AUTOSCALING ALARMS DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "api_cpu_utilization_high" {
  alarm_name          = "${var.application}-${var.environment}-API-CPU-Utilization-High-${var.ecs_as_cpu_high_threshold_per}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_cpu_high_threshold_per

  dimensions = {
    ClusterName = aws_ecs_cluster.api.name
    ServiceName = aws_ecs_service.api.name
  }

  alarm_actions = [aws_appautoscaling_policy.api_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  alarm_name          = "${var.application}-${var.environment}-API-CPU-Utilization-Low-${var.ecs_as_cpu_low_threshold_per}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_cpu_low_threshold_per

  dimensions = {
    ClusterName = aws_ecs_cluster.api.name
    ServiceName = aws_ecs_service.api.name
  }

  alarm_actions = [aws_appautoscaling_policy.api_down.arn]
}

# ---------------------------------------------------------------------------------------------------------------------
# API AUTOSCALING POLICIES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_appautoscaling_policy" "api_up" {
  name               = "api-scale-up"
  service_namespace  = aws_appautoscaling_target.api_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.api_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.api_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "api_down" {
  name               = "api-scale-down"
  service_namespace  = aws_appautoscaling_target.api_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.api_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.api_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# WEB AUTOSCALING ALARM DEFINTIONS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "web_cpu_utilization_high" {
  alarm_name          = "${var.application}-${var.environment}-WEB-CPU-Utilization-High-${var.ecs_as_cpu_high_threshold_per}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_cpu_high_threshold_per

  dimensions = {
    ClusterName = aws_ecs_cluster.web.name
    ServiceName = aws_ecs_service.web.name
  }

  alarm_actions = [aws_appautoscaling_policy.web_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_utilization_low" {
  alarm_name          = "${var.application}-${var.environment}-WEB-CPU-Utilization-Low-${var.ecs_as_cpu_low_threshold_per}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_cpu_low_threshold_per

  dimensions = {
    ClusterName = aws_ecs_cluster.web.name
    ServiceName = aws_ecs_service.web.name
  }

  alarm_actions = [aws_appautoscaling_policy.web_down.arn]
}

# ---------------------------------------------------------------------------------------------------------------------
# WEB AUTOSCALING POLICIES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_appautoscaling_policy" "web_up" {
  name               = "web-scale-up"
  service_namespace  = aws_appautoscaling_target.web_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.web_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.web_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "web_down" {
  name               = "web-scale-down"
  service_namespace  = aws_appautoscaling_target.web_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.web_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.web_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}