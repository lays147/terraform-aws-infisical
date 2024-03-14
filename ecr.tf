resource "aws_ecr_repository" "this" {
  count = local.ecr.hub_enabled ? 1 : 0
  name  = local.project
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
  tags         = local.tags
}

resource "aws_ecr_pull_through_cache_rule" "this" {
  count                 = local.ecr.hub_enabled ? 1 : 0
  ecr_repository_prefix = aws_ecr_repository.this[0].name
  upstream_registry_url = "registry-1.docker.io"
  credential_arn        = local.ecr.hub_secret
}
