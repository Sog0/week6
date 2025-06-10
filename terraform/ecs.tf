resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = "256"
  memory                  = "512"
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
  {
    name      = "sample-django"
    image     = "807906458847.dkr.ecr.us-east-1.amazonaws.com/sample-django:latest"
    essential = true
    portMappings = [
      {
        containerPort = 8000
        hostPort      = 8000
      }
    ]
    environment = [
      {
        name  = "DATABASE_URL"
        value = "postgres://django:password123@${aws_db_instance.postgres.endpoint}/sampledb"
      },
      {
        name  = "DJANGO_SECRET_KEY"
        value = "password123"
      },
      {
        name  = "DJANGO_ALLOWED_HOSTS"
        value = "*"
      },
      {
        name  = "DEBUG"
        value = "False"
      }  
    ]
    logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/sample-django"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }}
  }

])

}

resource "aws_ecs_service" "main" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.public_subnets[0].id,aws_subnet.public_subnets[1].id]
    security_groups  = [aws_security_group.main_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.demo_lb_tg.arn
    container_name   = "sample-django"
    container_port   = 8000
  }
  
}


############
# IAM ROLE #
############

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/sample-django"
  retention_in_days = 7
}


