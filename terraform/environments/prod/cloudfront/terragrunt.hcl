terraform {
  source = "../../../modules/cloudfront"
}

inputs = {
  s3_bucket_domain_name  = dependency.s3.outputs.bucket_name
  origin_access_identity = dependency.s3.outputs.bucket_arn
  tag_name               = "dor-checkpoint-cloudfront"
  tag_owner              = "Dor Knafo"
}

dependency "s3" {
  config_path = "../s3"
}
