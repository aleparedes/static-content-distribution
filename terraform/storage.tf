resource "aws_s3_bucket" "application_log_bucket" {
  bucket = "${var.application_bucket_name}-logs"
  acl    = "log-delivery-write"
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
    target_bucket = aws_s3_bucket.application_log_bucket.id
    target_prefix = "log/"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

