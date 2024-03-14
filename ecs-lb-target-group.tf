resource "aws_lb_target_group" "this" {
  name        = local.project
  port        = local.ecs.infisical.port
  protocol    = "HTTP"
  vpc_id      = local.networking.vpc_id
  target_type = "ip"

  health_check {
    port                = local.ecs.infisical.port
    matcher             = local.ecs.infisical.healthcheck.matcher
    path                = local.ecs.infisical.healthcheck.path
    interval            = local.ecs.infisical.healthcheck.interval
    healthy_threshold   = local.ecs.infisical.healthcheck.healthy_threshold
    unhealthy_threshold = local.ecs.infisical.healthcheck.unhealthy_threshold
  }
  tags = local.tags
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = data.aws_lb_listener.selected443.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [local.dns.domain]
    }
  }
  depends_on = [aws_lb_target_group.this]
  tags       = local.tags
}
