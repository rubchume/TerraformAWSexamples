provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "vpc_with_public_and_private_subnet" {
  source = "../modules/aws_vpc_with_subnets"

  public_subnets = {
    public_subnet_1 = {
      cidr_block        = "10.0.101.0/24",
      availability_zone = "eu-west-3a"
    }
    public_subnet_2 = {
      cidr_block        = "10.0.102.0/24",
      availability_zone = "eu-west-3b"
    }
  }
  private_subnets = {
    private_subnet = {
      cidr_block        = "10.0.1.0/24",
      availability_zone = "eu-west-3a"
    }
  }
  allowed_ports = flatten([for parameters in var.container_parameters : parameters.public_ports])

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

locals {
  container_definitions = [
  for parameters in var.container_parameters : {
    name : "${var.app_name}-${var.deployment_tag}-${parameters.container_name}",
    image : "${parameters.image}:latest",
    essential : true,
    logConfiguration : {
      logDriver : "awslogs",
      options : {
        "awslogs-group" : aws_cloudwatch_log_group.log-group.id,
        "awslogs-region" : var.aws_region,
        "awslogs-stream-prefix" : "${var.app_name}-${var.deployment_tag}"
      }
    },
    portMappings : [
    for port in parameters.public_ports :
    {
      containerPort : port
      hostPort : port
    }
    ],
    cpu : floor(var.number_of_cpus / length(var.container_parameters)),
    memory : floor(var.memory / length(var.container_parameters)),
    networkMode : "awsvpc"
  }
  ]
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.app_name
  execution_role_arn       = module.ecs_task_execution_role.service_role.arn
  task_role_arn            = module.ecs_task_role.service_role.arn
  network_mode             = "awsvpc"
  cpu                      = var.number_of_cpus
  memory                   = "1024"
  requires_compatibilities = ["FARGATE"]

  tags = {
    Deployment = var.deployment_tag
  }

  container_definitions = jsonencode(local.container_definitions)
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.task_definition.family
}

resource "aws_security_group" "service_security_group" {
  vpc_id = module.vpc_with_public_and_private_subnet.vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [module.vpc_with_public_and_private_subnet.security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Deployment = var.deployment_tag
  }
}

locals {
  container_parameters_by_container_name = {for container in var.container_parameters: container.container_name => container}
  main_container = local.container_parameters_by_container_name[var.main_container]
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
    subnets          = values(module.vpc_with_public_and_private_subnet.private_subnet_ids)
    assign_public_ip = false
    security_groups  = [
      module.vpc_with_public_and_private_subnet.security_group.id,
      aws_security_group.service_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.app_name}-${var.deployment_tag}-${local.main_container.container_name}"
    container_port   = element(local.main_container.public_ports, 0)
  }
}

resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "${var.app_name}-ecs-cluster"
  tags = {
    Deployment = var.deployment_tag
  }
}

resource "aws_alb" "application_load_balancer" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = values(module.vpc_with_public_and_private_subnet.public_subnet_ids)
  security_groups    = [module.vpc_with_public_and_private_subnet.security_group.id]

  tags = {
    Deployment = var.deployment_tag
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.app_name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc_with_public_and_private_subnet.vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/v1/status"
    unhealthy_threshold = "2"
  }

  tags = {
    Deployment = var.deployment_tag
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}


module "nat_gateway" {
  source = "../modules/aws_nat_gateway_for_subnet"

  vpc_id = module.vpc_with_public_and_private_subnet.vpc.id
  public_subnet_id = module.vpc_with_public_and_private_subnet.public_subnet_ids["public_subnet_1"]
  private_subnet_id = module.vpc_with_public_and_private_subnet.private_subnet_ids["private_subnet"]
}
