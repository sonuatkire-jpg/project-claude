# Terraform Configuration for Static Website on AWS
# Deployed to eu-north-1 region for project tejasatkireadmin


locals {
  tags = {
    Project    = var.project_name
    Environment = var.environment
  }
}

data "aws_caller_identity" "current" {}

# S3 Bucket for hosting static website
resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-${var.environment}-${random_string.bucket_suffix.id}"

  tags = local.tags
}

# Random suffix for bucket name uniqueness
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false

  keepers = {
    environment = var.environment
  }
}

# S3 Bucket Policy for CloudFront OAC access
resource "aws_s3_bucket_policy" "oac_policy" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontOACAccess",
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/AWSLambdaType2OriginAccessControlPolicy" }
        Action    = "s3:GetObject"
        Resource   = "arn:aws:s3:::${aws_s3_bucket.website.bucket}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI for ${var.project_name} ${var.environment}"
}


# CloudFront Distribution
resource "aws_cloudfront_distribution" "distribution" {
  origin {
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }

    domain_name = "${aws_s3_bucket.website.bucket}.s3.${var.region}.amazonaws.com"
    origin_id   = "WebsiteOrigin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "WebsiteOrigin"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  custom_error_response {
    error_caching_min_ttl = -1
    error_code            = "404"
    response_code         = "200"
    response_page_path    = "/index.html"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = local.tags
}


# VPC for Terraform state storage (optional, commented out)
# Uncomment if you need private state storage
# resource "aws_vpc" "state_storage" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = merge(local.tags, { Name = "${var.project_name}-state-storage-vpc" })
# }