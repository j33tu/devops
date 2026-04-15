output "bucket_arn" {
  description = "The ARN of the created S3 bucket"
  value       = aws_s3_bucket.s3bucket_name.arn # 'this' should match the resource name inside the module
}

