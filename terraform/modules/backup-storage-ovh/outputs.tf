output "bucket_name" {
  value       = ovh_cloud_project_storage.this.name
  description = "Name of the backup bucket"
}

output "endpoint" {
  value       = "https://s3.${lower(var.region)}.io.cloud.ovh.net"
  description = "S3 endpoint to pass to the AWS CLI as --endpoint-url"
}

output "region" {
  value       = lower(var.region)
  description = "Region to pass to the AWS CLI, which expects it in lower case"
}

output "access_key_id" {
  value       = ovh_cloud_project_user_s3_credential.backup.access_key_id
  description = "Access key ID for the backup user"
  sensitive   = true
}

output "secret_access_key" {
  value       = ovh_cloud_project_user_s3_credential.backup.secret_access_key
  description = "Secret access key for the backup user"
  sensitive   = true
}
