resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags = {
    Name      = var.tag_name
    Owner     = var.tag_owner
    Terraform = "True"
  }

  lifecycle {
    prevent_destroy = true
  }

  provisioner "local-exec" {
    when = create
    command = "echo 'Bucket created: ${self.bucket}'"
  }
}

data "aws_s3_bucket" "existing_bucket" {
  bucket = aws_s3_bucket.this.bucket
  depends_on = [aws_s3_bucket.this]
}
