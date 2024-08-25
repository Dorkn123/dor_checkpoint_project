data "aws_s3_bucket" "existing_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket" "this" {
  count = data.aws_s3_bucket.existing_bucket.id == "" ? 1 : 0

  bucket = var.bucket_name

  tags = {
    Name      = var.tag_name
    Owner     = var.tag_owner
    Terraform = "True"
  }
}
