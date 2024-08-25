variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
}

variable "s3_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket"
}

variable "origin_access_identity" {
  type        = string
  description = "CloudFront origin access identity"
}

variable "tag_name" {
  type        = string
  description = "Tag name for the CloudFront distribution"
  default     = "dor-checkpoint-cloudfront"
}

variable "tag_owner" {
  type        = string
  description = "Owner tag for the CloudFront distribution"
  default     = "Dor Knafo"
}
