terraform {
  source = "../../../modules/s3"
}

inputs = {
  bucket_name = "dor-checkpoint-assets-dev"
  environment = "dev"
  tag_name    = "dor-checkpoint-cloudfront"
  tag_owner   = "Dor Knafo"
}
