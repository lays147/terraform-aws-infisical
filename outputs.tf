output "infisical_dns" {
  value       = aws_route53_record.this.name
  description = "Infisical DNS"
}
