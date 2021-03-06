resource "aws_s3_bucket" "logs_bucket" {
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
    target_bucket = aws_s3_bucket.logs_bucket.id
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

resource "aws_s3_bucket_object" "entry_point" {
  bucket       = var.application_bucket_name
  key          = "index.html"
  source       = "../html/index.html"
  content_type = "text/html"
  depends_on = [
    aws_s3_bucket.application_bucket,
  ]
  tags = {
    owner = var.resource_owner_email
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
    target_bucket = aws_s3_bucket.logs_bucket.id
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

resource "null_resource" "static_content" {
  provisioner "local-exec" {
    command = "aws s3 cp --recursive ../html/static/ s3://${var.static_content_bucket_name}/static/"
  }
  depends_on = [
    aws_s3_bucket.static_content_bucket,
  ]
}

