locals {
  project = "infisical-vault-${terraform.workspace}"

  # Network Configuration
  networking = {
    vpc_id                          = var.networking.vpc_id
    subnets                         = var.networking.subnets_ids
    load_balancer_arn               = var.networking.load_balancer_arn
    load_balancer_security_group_id = var.networking.load_balancer_security_group_id
  }

  # DNS Configurations
  dns = {
    subdomain = var.dns.subdomain
    route_53 = {
      zone_id   = var.dns.route_53_zone_id
      zone_name = data.aws_route53_zone.this.name
    }
    domain = "${var.dns.subdomain}.${data.aws_route53_zone.this.name}"
  }

  # Postgres
  postgres = {
    user   = var.postgres.admin_username
    schema = var.postgres.default_schema
  }

  # Container Configuration
  ecs = {
    total_cpu    = var.ecs.total_cpu
    total_memory = var.ecs.total_memory
    cluster      = var.ecs.cluster_arn

    infisical = {
      migrations_cmd  = ["npm", "run", "migration:latest"]
      run_migrations  = var.run_infisical_migrations
      port            = 8080
      cpu             = var.ecs.infisical.cpu
      memory          = var.ecs.infisical.memory
      container_image = var.ecs.infisical.image
      desired_count   = 1
      healthcheck = {
        path                = "/api/status"
        interval            = 20
        matcher             = 200
        timeout             = 15
        healthy_threshold   = 3
        unhealthy_threshold = 2
      }
    }

    redis = {
      name            = "redis-${local.project}"
      container_image = var.ecs.redis.image
      cpu             = var.ecs.redis.cpu
      memory          = var.ecs.redis.memory
      port            = 6379
      healthcheck = {
        command = [
          "redis-cli",
          "ping"
        ]
        interval    = 30,
        timeout     = 5,
        retries     = 3,
        startPeriod = 60
      }
    }
  }

  # ECR Docker Hub Config
  ecr = {
    hub_enabled = var.ecr_use_pull_through_cache.enabled
    hub_secret  = var.ecr_use_pull_through_cache.docker_hub_secret_arn
  }
  tags = var.tags
}
