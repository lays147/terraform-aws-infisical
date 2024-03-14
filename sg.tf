resource "aws_security_group_rule" "elb-egress" {
  type                     = "egress"
  description              = "Allow ELB to call the app"
  from_port                = local.ecs.infisical.port
  to_port                  = local.ecs.infisical.port
  protocol                 = "tcp"
  source_security_group_id = module.ecs_service.security_group_id
  security_group_id        = local.networking.load_balancer_security_group_id
}
