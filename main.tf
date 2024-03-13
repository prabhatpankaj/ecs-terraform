provider "aws" {
  region = var.aws_region
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
}

output "cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-task"
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([{
    name            = "nginx-container"
    image           = "nginx:latest"
    cpu             = 256
    memory          = 512
    portMappings = [
      {
        containerPort = 80,
        hostPort      = 80,
        protocol      = "tcp",
      }
    ]
  }])
}

resource "aws_lb" "ecs_lb" {
  name               = "nginx-ecs-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "ecs_target_group" {
  name        = "ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_target_group_attachment" "ecs_attachment" {
  target_group_arn = aws_lb_target_group.ecs_target_group.arn
  target_id        = aws_ecs_task_definition.nginx_task.arn
}

resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-service"
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.nginx_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_grp]
    assign_public_ip = "true"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "nginx-container"
    container_port   = 80
  }
}

output "load_balancer_dns_name" {
  value = aws_lb.ecs_lb.dns_name
}
