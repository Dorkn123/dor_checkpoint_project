data "aws_s3_bucket" "existing_bucket" {
  bucket = var.bucket_name
  count  = try(length(aws_s3_bucket.this), 0) == 0 ? 1 : 0
}

resource "aws_s3_bucket" "this" {
  count = try(length(data.aws_s3_bucket.existing_bucket), 0) == 0 ? 1 : 0

  bucket = var.bucket_name

  tags = {
    Name      = var.tag_name
    Owner     = var.tag_owner
    Terraform = "True"
  }
}
