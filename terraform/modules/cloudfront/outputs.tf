output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.this.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_origin_access_identity_arn" {
  value = aws_cloudfront_origin_access_identity.this.iam_arn
}
