output "bucket_arn" {
  value = length(aws_s3_bucket.this) > 0 ? aws_s3_bucket.this[0].arn : (try(data.aws_s3_bucket.existing_bucket[0].arn, null))
}

output "bucket_name" {
  value = length(aws_s3_bucket.this) > 0 ? aws_s3_bucket.this[0].bucket : (try(data.aws_s3_bucket.existing_bucket[0].bucket, null))
}
