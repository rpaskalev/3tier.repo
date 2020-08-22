# cdn.tf

# ---------------------------------------------------------------------------------------------------------------------
# CDN SETUP
# ---------------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# CREATE THE S3 BUCKET
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "toptal-webdistribution" {
  bucket = "toptal-webdistribution"
  force_destroy = true
}


# ------------------------------------------------------------------------------
# CREATE CLOUDFRONT WEB DISTRIBUTION
# ------------------------------------------------------------------------------


resource "aws_cloudfront_origin_access_identity" "web_distribution" {
}

data "aws_iam_policy_document" "web_distribution" {
  statement {
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.web_distribution.iam_arn}"]
    }
    resources = ["${aws_s3_bucket.toptal-webdistribution.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "web_distribution" {
  bucket = aws_s3_bucket.toptal-webdistribution.id
  policy = data.aws_iam_policy_document.web_distribution.json
}

resource "aws_cloudfront_distribution" "web_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  wait_for_deployment = false
  price_class         = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket.toptal-webdistribution.bucket_regional_domain_name
    origin_id   = "web_distribution_origin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.web_distribution.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "web_distribution_origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
      headers = ["Origin"]
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

  }

  tags = {
    Name        = "cdn-${var.environment}"
    Environment = var.environment
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# ------------------------------------------------------------------------------
# UPLOAD THE STATIC RESOURCES TO S3
# ------------------------------------------------------------------------------

resource "null_resource" "remove_and_upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync /root/src/node-3tier-app/web/public s3://${aws_s3_bucket.toptal-webdistribution.id}"
  }
}