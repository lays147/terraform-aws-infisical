variable "ecr_use_pull_through_cache" {
  description = "Cache Infisical image to ECR from Docker Hub"
  type = object({
    enabled               = bool
    docker_hub_secret_arn = string
  })

  default = {
    docker_hub_secret_arn = ""
    enabled               = false
  }
  validation {
    condition     = var.ecr_use_pull_through_cache.enabled ? (var.ecr_use_pull_through_cache.docker_hub_secret_arn != "" ? true : false) : true
    error_message = "If enabled, docker_hub_secret_arn should be defined"
  }
}

variable "tags" {
  description = "Tags to use"
  default     = {}
  type        = map(string)
}

variable "networking" {
  description = "Network configuration"
  type = object({
    vpc_id                          = string
    subnets_ids                     = list(string)
    load_balancer_arn               = string
    load_balancer_security_group_id = string
  })
}

variable "dns" {
  description = "DNS Configuration"
  type = object({
    subdomain        = optional(string, "infisical")
    route_53_zone_id = string
  })
}

variable "postgres" {
  description = "Postgres Configuration"

  type = object({
    admin_username = string
    default_schema = string
  })

  default = {
    admin_username = "InfisicalAdmin"
    default_schema = "infisical"
  }
}

variable "ecs" {
  description = "ECS Configuration"
  type = object({
    cluster_arn = string

    total_cpu    = optional(number, 2048)
    total_memory = optional(number, 4096)

    infisical = object({
      image  = string
      cpu    = optional(number, 1024)
      memory = optional(number, 2028)
    })

    redis = optional(object({
      image  = string
      cpu    = number
      memory = number
      }), {
      image  = "bitnami/redis:latest"
      cpu    = 512
      memory = 1024
    })
  })

  validation {
    condition     = (var.ecs.infisical.cpu + var.ecs.redis.cpu) <= var.ecs.total_cpu && (var.ecs.infisical.memory + var.ecs.redis.memory) <= var.ecs.total_memory
    error_message = "Resources CPU/Memory cant be bigger than total allocated cpu and memory"
  }
}

variable "run_infisical_migrations" {
  description = "Run database migrations"
  type        = bool
  default     = false
}
