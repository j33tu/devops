
module "s3bucketprod" {
  source             = "./modules/s3bucket"
  bucket_name_prefix = "prod"
  s3bucketname       = "g2bucket"
  location           = "ap-south-1"

}
module "s3bucketstage" {
  source             = "./modules/s3bucket"
  bucket_name_prefix = "stage"
  s3bucketname       = "g2bucket"
  location           = "ap-south-1"

}
