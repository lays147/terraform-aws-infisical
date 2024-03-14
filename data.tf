data "aws_lb" "this" {
  arn = var.networking.load_balancer_arn
}

data "aws_lb_listener" "selected443" {
  load_balancer_arn = data.aws_lb.this.arn
  port              = 443
}

data "aws_route53_zone" "this" {
  zone_id = var.dns.route_53_zone_id
}
