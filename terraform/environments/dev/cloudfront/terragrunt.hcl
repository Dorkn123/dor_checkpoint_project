terraform {
  source = "../../../modules/cloudfront"
}

inputs = {
  bucket_name = "dor-checkpoint-assets-${local.environment}"
  environment = local.environment
  tag_name    = "dor-checkpoint-cloudfront"
  tag_owner   = "Dor Knafo"
}

locals {
  environment = basename(path_relative_to_include())
}