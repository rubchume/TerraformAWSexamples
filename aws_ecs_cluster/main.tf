provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "vpc_with_public_subnet" {
  source = "../modules/aws_vpc_public_subnet"

  subnet_availability_zone = "${var.aws_region}a"

  additional_tags = {
    Deployment = var.deployment_tag,
  }
}

module "ecs_task_execution_role" {
  source = "../modules/aws_service_role"

  service_role_name = "ecs_task_execution_role"
  additional_tags   = {
    Deployment = var.deployment_tag
  }
  service_principal = "ecs-tasks.amazonaws.com"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = module.ecs_task_execution_role.service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


module "ecs_task_role" {
  source = "../modules/aws_service_role"

  service_role_name = "ecs_task_role"
  additional_tags   = {
    Deployment = var.deployment_tag
  }
  service_principal = "ecs-tasks.amazonaws.com"
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = module.ecs_task_role.service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "${var.app_name}-${var.deployment_tag}-logs"

  tags = {
    Application = var.app_name
    Deployment  = var.deployment_tag
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.app_name
  execution_role_arn       = module.ecs_task_execution_role.service_role.arn
  task_role_arn            = module.ecs_task_role.service_role.arn
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "1024"
  requires_compatibilities = ["FARGATE"]

  tags = {
    Deployment = var.deployment_tag
  }

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.app_name}-container",
      "image": "${var.ecr_repository_url}:latest",
      "entryPoint": [],
      "environment": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "${var.app_name}-${var.deployment_tag}"
        }
      },
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        },
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.task_definition.family
}

resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "${var.app_name}-ecs-cluster"
  tags = {
    Deployment = var.deployment_tag
  }
}


resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.app_name}-ecs-service"
  cluster              = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition      = aws_ecs_task_definition.task_definition.family
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = [module.vpc_with_public_subnet.subnet_id]
    assign_public_ip = true
    security_groups  = [
      module.vpc_with_public_subnet.security_group.id
    ]
  }
}
