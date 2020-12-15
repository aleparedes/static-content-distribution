# Local variables -------------------------------------------
locals {
  domain_name           = var.domain_name
  application_origin    = "application_origin"
  static_content_origin = "static_content_origin"
}

# Route53 -------------------------------------------
resource "aws_route53_zone" "root" {
  name = local.domain_name
  tags = {
    owner = var.resource_owner_email
  }
}

resource "aws_route53_record" "www_app" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "www"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.static_content_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.static_content_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "example_app" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "example"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.static_content_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.static_content_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root_app" {
  zone_id = aws_route53_zone.root.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.static_content_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.static_content_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# Cloudfront -------------------------------------------
resource "aws_cloudfront_distribution" "static_content_distribution" {
  default_root_object = "index.html"
  is_ipv6_enabled     = false
  enabled             = true
  price_class         = "PriceClass_100"
  wait_for_deployment = false
  tags = {
    owner = var.resource_owner_email
  }

  origin {
    domain_name = aws_s3_bucket.application_bucket.bucket_regional_domain_name
    origin_id   = local.application_origin
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.application_bucket_oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_s3_bucket.static_content_bucket.bucket_regional_domain_name
    origin_id   = local.static_content_origin
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static_content_bucket_oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = local.application_origin
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
      headers = ["Origin"]
    }
    viewer_protocol_policy = "redirect-to-https"
    # viewer_protocol_policy = "allow-all"
    min_ttl     = 0
    default_ttl = 3000
    max_ttl     = 50000
    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.static_content_distribution_authorizer.qualified_arn
      include_body = false
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/static/*"
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = local.static_content_origin
    forwarded_values {
      query_string = false
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 3000
    max_ttl                = 50000
    compress               = true
    viewer_protocol_policy = "allow-all"
  }
  aliases = [var.domain_name]
  # viewer_certificate {
  #   cloudfront_default_certificate = true
  # }
  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  web_acl_id = aws_waf_web_acl.AccessControlList.id
}

# Origin Access Identity -------------------------------------------
resource "aws_cloudfront_origin_access_identity" "application_bucket_oai" {
  comment = "aws_cloudfront_origin_access_identity for the application "
}

data "aws_iam_policy_document" "application_bucket_oai_policy" {
  statement {
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.application_bucket_oai.iam_arn}"]
    }
    resources = ["${aws_s3_bucket.application_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "application_bucket_oai_policy" {
  bucket = aws_s3_bucket.application_bucket.id
  policy = data.aws_iam_policy_document.application_bucket_oai_policy.json
}

resource "aws_cloudfront_origin_access_identity" "static_content_bucket_oai" {
  comment = "aws_cloudfront_origin_access_identity for the static content "
}

data "aws_iam_policy_document" "static_content_bucket_oai_policy" {
  statement {
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.static_content_bucket_oai.iam_arn}"]
    }
    resources = ["${aws_s3_bucket.static_content_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "static_content_bucket_oai_policy" {
  bucket = aws_s3_bucket.static_content_bucket.id
  policy = data.aws_iam_policy_document.static_content_bucket_oai_policy.json
}
