# TODO: remove once the Droplet has been decommissioned
output "droplet_ip" {
  value       = module.pds_droplet.ip_address
  description = "IP address of the DigitalOcean Droplet"
}

output "server_ip" {
  value       = module.pds_instance.ip_address
  description = "IP address of the OVH PDS instance"
}

output "backup_bucket_name" {
  value       = module.pds_backup_storage.bucket_name
  description = "Name of the backup bucket"
}

output "backup_endpoint" {
  value       = module.pds_backup_storage.endpoint
  description = "S3 endpoint for the backup bucket"
}

output "backup_region" {
  value       = module.pds_backup_storage.region
  description = "Region of the backup bucket, as the AWS CLI expects it"
}

output "backup_access_key_id" {
  value       = module.pds_backup_storage.access_key_id
  description = "Access key ID for the backup user"
  sensitive   = true
}

output "backup_secret_access_key" {
  value       = module.pds_backup_storage.secret_access_key
  description = "Secret access key for the backup user"
  sensitive   = true
}
