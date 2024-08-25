output "bucket_arn" {
  value = length(aws_s3_bucket.this) > 0 ? aws_s3_bucket.this[0].arn : data.aws_s3_bucket.existing_bucket.arn
}

output "bucket_name" {
  value = length(aws_s3_bucket.this) > 0 ? aws_s3_bucket.this[0].bucket : data.aws_s3_bucket.existing_bucket.bucket
}
