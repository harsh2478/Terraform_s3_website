resource "random_integer" "priority" {
  min     = 1
  max     = 50000
}

resource "aws_s3_bucket" "website" {
  bucket = "my-s3-static-website-${random_integer.priority.result}"

  tags = {
    Name        = "My Website"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "unblock" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership,
    aws_s3_bucket_public_access_block.unblock,
  ]

  bucket = aws_s3_bucket.website.id
  acl    = "public-read"
}

resource "aws_s3_object" "index_object" {
  bucket = aws_s3_bucket.website.id
  key    = "index.html"
  source = "./index.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "error_object" {
  bucket = aws_s3_bucket.website.id
  key    = "error.html"
  source = "./error.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "profile-pic" {
  bucket = aws_s3_bucket.website.id
  key    = "profile-pic.png"
  source = "./profile-pic.png"
  acl = "public-read"
}


resource "aws_s3_bucket_website_configuration" "portfolio" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket_acl.example]
}