resource "aws_ecs_task_definition" "api_task" {
  family                   = "${var.env}_family"
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  container_definitions    = jsonencode([
    {
      name             = "${var.env}_api"
      image            = var.task_image
      essential        = true
      portMappings     = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logdriver = "awslogs"
        options   = {
          "awslogs-group"         = "/ecs/api"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "stdout"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "service" {
  name                 = "${var.env}_service"
  cluster              = var.cluster_id
  task_definition      = aws_ecs_task_definition.api_task.family
  launch_type          = "FARGATE"
  desired_count        = 1

  network_configuration {
    subnets         = var.task_subnets
    security_groups = [var.internal_sg]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.task_tg.arn
    container_name   = "${var.env}_api"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.task_listener]
}
