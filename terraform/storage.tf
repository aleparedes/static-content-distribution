resource "aws_s3_bucket" "static_content_distribution_log_bucket" {
  bucket        = "static-content-distribution-logs"
  acl           = "log-delivery-write"
  force_destroy = var.force_destroy_bucket
  tags = {
    owner = var.resource_owner_email
  }
}

resource "aws_s3_bucket" "application_bucket" {
  bucket        = var.application_bucket_name
  acl           = "private"
  force_destroy = var.force_destroy_bucket
  versioning {
    enabled = true
  }
  tags = {
    owner = var.resource_owner_email
  }
  logging {
    target_bucket = aws_s3_bucket.static_content_distribution_log_bucket.id
    target_prefix = "application-log/"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "static_content_bucket" {
  bucket        = var.static_content_bucket_name
  acl           = "private"
  force_destroy = var.force_destroy_bucket
  versioning {
    enabled = true
  }
  tags = {
    owner = var.resource_owner_email
  }
  logging {
    target_bucket = aws_s3_bucket.static_content_distribution_log_bucket.id
    target_prefix = "static-content-log/"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
