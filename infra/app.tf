resource "aws_alb_target_group" "app" {
  name        = "app-target-group"
  port        = var.app_port
  protocol    = var.app_tg_protocol
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = var.app_tg_protocol
    matcher             = "200-499"
    timeout             = "3"
    path                = var.app_health_check_path
    unhealthy_threshold = "2"
  }
  tags = {
    Name = "app-target-group"
  }
}

# auto_scaling.tf

resource "aws_appautoscaling_target" "app" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.app_min_capacity
  max_capacity       = var.app_max_capacity
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "app_up" {
  name               = "app_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 10
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.app]
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "app_down" {
  name               = "app_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 10
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.app]
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "app_service_cpu_high" {
  alarm_name          = "app_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  alarm_actions = [aws_appautoscaling_policy.app_up.arn]
  tags = {
    Name = "app_cpu_utilization_high"
  }
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "app_service_cpu_low" {
  alarm_name          = "app_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  alarm_actions = [aws_appautoscaling_policy.app_down.arn]
  tags = {
    Name = "app_cpu_utilization_low"
  }
}

## task definition and service

data "aws_caller_identity" "current" {}

data "template_file" "app" {
  template = file("./templates/ecs/app.json.tpl")

  vars = {
    app_image      = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.cluster_name}/${var.app_name}:latest"
    app_port       = var.app_port
    fargate_cpu    = var.app_fargate_cpu
    fargate_memory = var.app_fargate_memory
    aws_region     = var.aws_region
    app_name       = var.app_name
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.app_name
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_fargate_cpu
  memory                   = var.app_fargate_memory
  container_definitions    = data.template_file.app.rendered
}

resource "aws_ecs_service" "app" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.app.id]
    subnets          = var.subnets_list
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = var.app_name
    container_port   = var.app_port
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_roleECR, aws_iam_role_policy_attachment.ecs_task_execution_roleECS]
}

# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/ecs/app"
  retention_in_days = 30

  tags = {
    Name = "app-log-group"
  }  
}

resource "aws_cloudwatch_log_stream" "app_log_stream" {
  name           = "app-log-stream"
  log_group_name = aws_cloudwatch_log_group.app_log_group.name
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "app" {
  name        = "app-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "app-security-group"
  } 
}

resource "aws_ecr_repository" "app" {
  name                 = var.app_ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = var.app_ecr_repo_name
  } 
}