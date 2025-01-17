resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }

  tags = {
    Name      = var.tag_name
    Owner     = var.tag_owner
    Terraform = "True"
    Description = "S3 bucket for ${var.bucket_name} in ${var.environment} environment"
  }
}
