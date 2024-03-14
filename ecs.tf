module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "v5.10.0"

  name               = local.project
  cluster_arn        = local.ecs.cluster
  enable_autoscaling = false

  cpu                 = local.ecs.total_cpu
  memory              = local.ecs.total_memory
  subnet_ids          = local.networking.subnets
  security_group_name = local.project
  load_balancer = {
    service = {
      target_group_arn = aws_lb_target_group.this.arn
      container_name   = local.project
      container_port   = local.ecs.infisical.port
    }
  }

  security_group_rules = {
    alb_ingress_8080 = {
      type                     = "ingress"
      from_port                = local.ecs.infisical.port
      to_port                  = local.ecs.infisical.port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = local.networking.load_balancer_security_group_id
    }

    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Container definition(s)
  container_definitions = {

    (local.project) = {
      cpu        = local.ecs.infisical.cpu
      memory     = local.ecs.infisical.memory
      essential  = true
      image      = local.ecs.infisical.container_image
      entrypoint = local.ecs.infisical.run_migrations ? local.ecs.infisical.migrations_cmd : []

      port_mappings = [
        {
          name          = local.project
          containerPort = local.ecs.infisical.port
          hostPort      = local.ecs.infisical.port
          protocol      = "tcp"
        }
      ]

      secrets = [
        { name = "DB_CONNECTION_URI", valueFrom = aws_ssm_parameter.postgres.arn },
        { name = "ENCRYPTION_KEY", valueFrom = aws_ssm_parameter.encryption_key.arn },
        { name = "AUTH_SECRET", valueFrom = aws_ssm_parameter.auth_secret.arn },
      ]

      environment = [
        { name = "REDIS_URL", value = "redis://127.0.0.1:6379" },
        { name = "SITE_URL", value = "https://${local.dns.domain}" },
        { name = "PINO_LOG_LEVEL", value = "debug" }
      ]
      readonly_root_filesystem = false
    }

    redis = {
      image     = local.ecs.redis.container_image
      cpu       = local.ecs.redis.cpu
      memory    = local.ecs.redis.memory
      essential = true
      port_mappings = [
        {
          name          = local.ecs.redis.name
          containerPort = local.ecs.redis.port
          hostPort      = local.ecs.redis.port
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "ALLOW_EMPTY_PASSWORD", value = "yes" }
      ]
      readonly_root_filesystem = false
      healthcheck              = local.ecs.redis.healthcheck
    }
  }

  task_exec_ssm_param_arns = [
    aws_ssm_parameter.postgres.arn,
    aws_ssm_parameter.encryption_key.arn,
    aws_ssm_parameter.auth_secret.arn,
  ]

  tags = local.tags
}
