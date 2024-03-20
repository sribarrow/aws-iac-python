#Creating S3 bucket for storing user content from Rest API Call

resource "aws_s3_bucket" "user_content_bucket" {
  bucket = var.user_bucket
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "user_content_bucket" {
  bucket = aws_s3_bucket.user_content_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "user_content_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.user_content_bucket]

  bucket = aws_s3_bucket.user_content_bucket.id
  acl    = "private"
}

# Creating S3 bucket for web hosting (front-end)

resource "aws_s3_bucket" "file_uploader_app_bucket" {
  bucket = var.webapp_bucket
  force_destroy = true

  tags = {
    Name = "File Uploader Service App Bucket"
  }
}

data "aws_iam_policy_document" "access_for_cloudfront" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cfd.iam_arn]
    }

    actions   = ["s3:GetObject", "s3:ListBucket" ]
    resources = [
                  aws_s3_bucket.file_uploader_app_bucket.arn, 
                  "${aws_s3_bucket.file_uploader_app_bucket.arn}/*"
                ]
  }
}

resource "aws_s3_bucket_policy" "access_for_cloudfront" {
  bucket = aws_s3_bucket.file_uploader_app_bucket.id
  policy = data.aws_iam_policy_document.access_for_cloudfront.json
}

resource "aws_s3_bucket_ownership_controls" "file_uploader_app_bucket_owner" {
  bucket = aws_s3_bucket.file_uploader_app_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "file_uploader_app_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.file_uploader_app_bucket_owner]
  bucket = aws_s3_bucket.file_uploader_app_bucket.id
  acl    = "private"
}
