module "s3_backend_application_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = format(module.naming.result, "backend-bucket")

  force_destroy            = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  acl                      = "private"

  # S3 bucket-level Public Access Block configuration (by default now AWS has made this default as true for S3 bucket-level block public access)
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  attach_policy = true
  policy = templatefile(
    "./files/backend-bucket-policy.tftpl",
    {
      s3_bucket_arn = "arn:aws:s3:::${format(module.naming.result, "backend-bucket")}"
    }
  )
}
