# 11 - Create ECS resources 
# Warning: There are no free-tier for Fargate. For matter of learn you can run it as long as you need (to get logs and metrics). *
# Warning: There are no free-tier for VPC Endpoints. For matter of learn you can run it as long as you need (to get logs and metrics). *

# Create Cluster (name=ghost)
# Create private ECR repository.
# Clone ghost image from Docker hub to ECR repository.
# Fargate tasks will have no Public IP and cannot access AWS services via Internet. Therefore you have to configure VPC Endpoints for the following services: SSM, ECR, EFS, S3, CloudWatch and CloudWatch logs services. You have to assign all interface type VPC endpoints with {vpc_endpoint} security group. Gateway type VPC endpoint should be assigned with private network routing table:{private_rt}.
# Author ECS Task definition:

# Type: Fargate
# Image: Ghost image path in ECR
# CPU limits: 256
# RAM limits: 1024
# Network mode: awsvpc
# Attach EFS volume to a container (mount path {/var/lib/ghost/content})
# Define DB related parameters as variables. DB related variables you can get from this example 
# Atach IAM role {ghost_app} as execution iam role
# Create ECS Service attach it to ALB target group {ghost-fargate}. Configure service to run in private subnets and assign it with {fargate_pool} security group.
# DO NOT assign Public IP in a network configuration! *
# You can refer to the container documentation on Docker hub

resource "aws_kms_key" "ecs-kms-key" {
  description             = "ecs-kms-key"
  deletion_window_in_days = 7
}

resource "aws_ecs_cluster" "ghost" {
  name = "ghost"
  setting {
      name  = "containerInsights"
      value = "enabled"
      }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.ecs-kms-key.id
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = "ghost-ecs"
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ghost" {
  cluster_name = aws_ecs_cluster.ghost.name
  capacity_providers = ["FARGATE","FARGATE_SPOT"]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecr_repository" "ghost-ecr" {
  name                 = "ghost"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecs_task_definition" "ghost" {
  family                    = "service"
  task_role_arn             = "arn:aws:iam::301684269231:role/ghost_app"
  execution_role_arn        = "arn:aws:iam::301684269231:role/ecs-task-exec-role"
  cpu                       = "256"
  memory                    = "1024"
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  volume {
    name = "ghost_content"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.ghost_content.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.ghost_efs_access_point.id
        iam             = "ENABLED"
      }
     }
   }
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
        {
      cpu       = 256
      memory    = 1024
      networkMode = "awsvpc"
      name      = "ghost"
      image     = "301684269231.dkr.ecr.eu-central-1.amazonaws.com/ghost:latest"
      essential = true
      mountPoints = [{
        containerPath = "/var/lib/ghost/content",
        sourceVolume = "ghost_content"
      }]
      environment = [{"name": "database__client", "value": "mysql"},
        # {"name":"database__connection__host", "value":"${aws_db_instance.ghost.endpoint}"},
        {"name":"database__connection__host", "value":"ghost.c49ddsdb5lsb.eu-central-1.rds.amazonaws.com"},
        {"name":"database__connection__user", "value":"ghost"},
        {"name":"database__connection__password", "value":"${random_password.randompass.result}"},
        {"name":"database__connection__database", "value":"ghost"}]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-region"= "eu-central-1"
          "awslogs-group"= "ghost-ecs"
          "awslogs-stream-prefix"= "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 2368
          hostPort      = 2368
        }
      ]
    }
  ])
}
#

resource "aws_ecs_service" "ghost" {
  name            = "ghost"
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.ghost.id
  task_definition = aws_ecs_task_definition.ghost.arn
  force_new_deployment = true
  desired_count   = 4
  load_balancer {
    target_group_arn = aws_lb_target_group.ghost-alb-fargate.arn
    container_name   = "ghost"
    container_port   = 2368
  }
  network_configuration {
    subnets = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
    security_groups = [aws_security_group.fargate_pool.id]
  }
}

