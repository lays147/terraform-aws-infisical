resource "random_id" "encryption_key" {
  byte_length = 16
}

resource "random_id" "auth_secret" {
  byte_length = 32
}

resource "aws_ssm_parameter" "postgres" {
  name        = "/${local.project}/DB_CONNECTION_URI"
  description = "Postgres connection URL"
  type        = "SecureString"
  value       = "postgresql://${module.aurora_postgresql_v2.cluster_master_username}:${module.aurora_postgresql_v2.cluster_master_password}@${module.aurora_postgresql_v2.cluster_endpoint}:5432/${local.postgres.schema}"
  tags        = local.tags
}

resource "aws_ssm_parameter" "encryption_key" {
  name        = "/${local.project}/ENCRYPTION_KEY"
  description = "Infisical Encryption Key"
  type        = "SecureString"
  value       = random_id.encryption_key.hex
  tags        = local.tags
}


resource "aws_ssm_parameter" "auth_secret" {
  name        = "/${local.project}/AUTH_SECRET"
  description = "Infisical Auth Secret"
  type        = "SecureString"
  value       = random_id.auth_secret.b64_std
  tags        = local.tags
}
