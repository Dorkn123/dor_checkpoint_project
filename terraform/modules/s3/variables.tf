variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
  default     = "dor-checkpoint-assets-dev"  
}

variable "tag_name" {
  type        = string
  description = "Tag name for the S3 bucket"
  default     = "dor-checkpoint-cloudfront"  
}

variable "tag_owner" {
  type        = string
  description = "Owner tag for the S3 bucket"
  default     = "Dor Knafo"  
}

variable "environment" {
  type        = string
  description = "The environment in which the resources are deployed (e.g., dev, prod)."
}

