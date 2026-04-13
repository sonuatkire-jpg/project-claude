# Terraform Outputs
# Export values after apply

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.distribution.id
  sensitive   = false
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (URL to access your site)"
  value       = aws_cloudfront_distribution.distribution.domain_name
  sensitive   = false
}

output "s3_bucket_name" {
  description = "S3 bucket name hosting the static website"
  value       = aws_s3_bucket.website.bucket
  sensitive   = false
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.website.arn
  sensitive   = false
}

output "random_bucket_suffix" {
  description = "Random suffix used for S3 bucket name"
  value       = random_string.bucket_suffix.id
  sensitive   = false
}
