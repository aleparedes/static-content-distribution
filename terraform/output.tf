output "application_bucket_id" {
  value = aws_s3_bucket.application_bucket.id
}

output "application_bucket_region" {
  value = aws_s3_bucket.application_bucket.region
}

output "static_content_bucket_id" {
  value = aws_s3_bucket.static_content_bucket.id
}

output "static_content_bucket_region" {
  value = aws_s3_bucket.static_content_bucket.region
}

output "logs_bucket_id" {
  value = aws_s3_bucket.logs_bucket.id
}

output "logs_bucket_region" {
  value = aws_s3_bucket.logs_bucket.region
}

output "static_content_distribution_authorizer_arn" {
  value = aws_lambda_function.static_content_distribution_authorizer.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.static_content_distribution.*.domain_name
}
