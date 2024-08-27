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

  # Check if the bucket already exists
  provisioner "local-exec" {
    when = create
    command = "echo 'Bucket created: ${self.bucket}'"
    on_failure = continue
  }

  # If the bucket already exists, skip creation
  depends_on = [
    aws_s3_bucket.this
  ]
}
