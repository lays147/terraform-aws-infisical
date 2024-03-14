resource "aws_route53_record" "this" {
  zone_id = local.dns.route_53.zone_id
  name    = local.dns.subdomain
  type    = "A"

  alias {
    name                   = data.aws_lb.this.dns_name
    zone_id                = data.aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

