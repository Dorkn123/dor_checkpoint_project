terraform {
  source = "../../../modules/cloudfront"
}

inputs = {
  bucket_name = "dor-checkpoint-assets-dev"
  bucket_arn  = "arn:aws:s3:::dor-checkpoint-assets-dev"
  tag_name    = "dor-checkpoint-cloudfront"
  tag_owner   = "Dor Knafo"
}
