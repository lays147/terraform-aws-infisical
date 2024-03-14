# Infisical Vault Terraform Module

[Infisical](https://infisical.com/) is a secrets and config manager. They have an open source version that could fit in a 
lot of your use cases.

Besides, from the available open source solutions available, they have a beautiful interface and have more features that doesn't limit you in the Open Source version, and I think this is amazing.

With this terraform module you can setup a Infisical Vault in AWS using the ECS + Postgres setup.

## Architecture

ECS + Aurora Postgres Serverless

## Module Configuration

```tf
module "infisical" {
  source = "git@github.com:lays147/terraform-infisical.git?ref=main"
  tags   = {}
  networking = {
    vpc_id                          = ""
    subnets_ids                     = ""
    load_balancer_arn               = ""
    load_balancer_security_group_id = ""
  }
  dns = {
    route_53_zone_id = ""
  }

  ecs = {
    cluster_arn = ""
    infisical = {
      image = ""
    }
  }
}
```

### First Run 
When setting up this module for the first time, the variable `run_infisical_migrations` must be `true` otherwhise Infisical will not start. After the migrations are ran, you can set this variable to `false` and then the server will be able to start.

## How to contribute

- Clone/Fork this repository
- Install pre-commit
- Write your changes
- Open a PR =) 

## Observations

- The Postgres configuration is hard coded to use the `"13.12"` Aurora Serverless version. If you plan to have a heavy use of the Infisical, it's recomended to migrate the database to RDS. Feel free to contribute in this module to support RDS and Serverless.
- The Redis instance runs as a sidecar together with the main container in the same task definition. The Memory and CPU of the ECS Service is shared between the Redis and the Infisical Container
- The Redis instance does not have a password configured.
- The Postgres connection uses the admin user and password. It's not the best scenario, but this module can be edited to support a user and password as an input. You can check this [series of blog posts](https://lays147.substack.com/p/manage-your-rds-instance-like-a-hero) to check how can you use Terraform + Ansible to manage a RDS instance.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.40.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aurora_postgresql_v2"></a> [aurora\_postgresql\_v2](#module\_aurora\_postgresql\_v2) | terraform-aws-modules/rds-aurora/aws | ~>v9.2.1 |
| <a name="module_ecs_service"></a> [ecs\_service](#module\_ecs\_service) | terraform-aws-modules/ecs/aws//modules/service | v5.10.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_pull_through_cache_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group_rule.elb-egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.auth_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_id.auth_secret](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/id) | resource |
| [random_id.encryption_key](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/id) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/password) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_lb_listener.selected443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb_listener) | data source |
| [aws_rds_engine_version.postgresql](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_engine_version) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns"></a> [dns](#input\_dns) | DNS Configuration | <pre>object({<br>    subdomain        = optional(string, "infisical")<br>    route_53_zone_id = string<br>  })</pre> | n/a | yes |
| <a name="input_ecr_use_pull_through_cache"></a> [ecr\_use\_pull\_through\_cache](#input\_ecr\_use\_pull\_through\_cache) | Cache Infisical image to ECR from Docker Hub | <pre>object({<br>    enabled               = bool<br>    docker_hub_secret_arn = string<br>  })</pre> | <pre>{<br>  "docker_hub_secret_arn": "",<br>  "enabled": false<br>}</pre> | no |
| <a name="input_ecs"></a> [ecs](#input\_ecs) | ECS Configuration | <pre>object({<br>    cluster_arn = string<br><br>    total_cpu    = optional(number, 2048)<br>    total_memory = optional(number, 4096)<br><br>    infisical = object({<br>      image  = string<br>      cpu    = optional(number, 1024)<br>      memory = optional(number, 2028)<br>    })<br><br>    redis = optional(object({<br>      image  = string<br>      cpu    = number<br>      memory = number<br>      }), {<br>      image  = "bitnami/redis:latest"<br>      cpu    = 512<br>      memory = 1024<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_networking"></a> [networking](#input\_networking) | Network configuration | <pre>object({<br>    vpc_id                          = string<br>    subnets_ids                     = list(string)<br>    load_balancer_arn               = string<br>    load_balancer_security_group_id = string<br>  })</pre> | n/a | yes |
| <a name="input_postgres"></a> [postgres](#input\_postgres) | Postgres Configuration | <pre>object({<br>    admin_username = string<br>    default_schema = string<br>  })</pre> | <pre>{<br>  "admin_username": "InfisicalAdmin",<br>  "default_schema": "infisical"<br>}</pre> | no |
| <a name="input_run_infisical_migrations"></a> [run\_infisical\_migrations](#input\_run\_infisical\_migrations) | Run database migrations | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to use | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_infisical_dns"></a> [infisical\_dns](#output\_infisical\_dns) | Infisical DNS |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
