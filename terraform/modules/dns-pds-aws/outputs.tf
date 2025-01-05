output "pds_fqdn" {
  value       = aws_route53_record.pds.fqdn
  description = "Domain name the PDS can be accessed at"
}
