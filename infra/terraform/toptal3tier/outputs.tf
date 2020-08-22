# outputs.tf

output "alb_api_hostname" {
  description = "The hostname of the API load balancer."
  value = aws_alb.api.dns_name
}

output "alb_web_hostname" {
  description = "The hostname of the WEB load balancer."
  value = aws_alb.web.dns_name
}


output "cloudfront_distribution_hostname" {
  description = "The hostname of the CloudFront Distribution"
  value       = aws_cloudfront_distribution.web_distribution.domain_name
}