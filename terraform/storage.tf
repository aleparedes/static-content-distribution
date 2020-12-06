
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
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

