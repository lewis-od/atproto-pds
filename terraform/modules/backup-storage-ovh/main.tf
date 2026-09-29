terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 2.21"
    }
  }
}

resource "ovh_cloud_project_storage" "this" {
  service_name = var.service_name
  region_name  = var.region
  name         = var.bucket_name

  encryption = {
    sse_algorithm = "AES256"
  }

  versioning = {
    status = "enabled"
  }

  # Without this every backed up object is read into Terraform state on each plan
  hide_objects = true
}

resource "ovh_cloud_project_storage_object_bucket_lifecycle_configuration" "this" {
  service_name   = ovh_cloud_project_storage.this.service_name
  region_name    = ovh_cloud_project_storage.this.region_name
  container_name = ovh_cloud_project_storage.this.name

  rules = [
    {
      id     = "expire-overwritten-backups"
      status = "enabled"
      noncurrent_version_expiration = {
        noncurrent_days = var.retention_days
      }
    },
    {
      id     = "abort-incomplete-uploads"
      status = "enabled"
      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }
    },
  ]
}

resource "ovh_cloud_project_user" "backup" {
  service_name = var.service_name
  description  = "Backup writer for ${var.bucket_name}"
  role_names   = ["objectstore_operator"]
}

resource "ovh_cloud_project_user_s3_credential" "backup" {
  service_name = ovh_cloud_project_user.backup.service_name
  user_id      = ovh_cloud_project_user.backup.id
}

# objectstore_operator grants project-wide access, so narrow it to this one bucket
resource "ovh_cloud_project_user_s3_policy" "backup" {
  service_name = ovh_cloud_project_user.backup.service_name
  user_id      = ovh_cloud_project_user.backup.id

  policy = jsonencode({
    Statement = [
      {
        Sid    = "BackupBucketReadWrite"
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
        ]
        Resource = [
          "arn:aws:s3:::${ovh_cloud_project_storage.this.name}",
          "arn:aws:s3:::${ovh_cloud_project_storage.this.name}/*",
        ]
      },
    ]
  })
}
