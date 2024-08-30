variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
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
