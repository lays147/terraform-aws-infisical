data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "13.12"

  filter {
    name   = "engine-mode"
    values = ["serverless"]
  }
}

resource "random_password" "this" {
  length  = 40
  special = true
}

module "aurora_postgresql_v2" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~>v9.2.1"

  name                = local.project
  database_name       = local.postgres.schema
  engine              = data.aws_rds_engine_version.postgresql.engine
  engine_mode         = "provisioned"
  engine_version      = data.aws_rds_engine_version.postgresql.version
  storage_encrypted   = true
  deletion_protection = true

  vpc_id                 = local.networking.vpc_id
  subnets                = local.networking.subnets
  create_db_subnet_group = true
  create_security_group  = true
  copy_tags_to_snapshot  = true

  master_username                     = local.postgres.user
  master_password                     = random_password.this.result
  manage_master_user_password         = false
  iam_database_authentication_enabled = false
  monitoring_interval                 = 60
  security_group_rules = {
    infisical = {
      source_security_group_id = module.ecs_service.security_group_id
    }
  }

  serverlessv2_scaling_configuration = {
    min_capacity = 1
    max_capacity = 2
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
  }
  tags = local.tags
}
