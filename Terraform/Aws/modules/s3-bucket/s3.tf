

resource "aws_s3_bucket" "s3bucket_name" {
  bucket = "${var.bucket_name_prefix}-${var.s3bucketname}-${var.location}"
}

