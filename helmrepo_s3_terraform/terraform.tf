provider "aws" {
  region                   = var.region
  shared_credentials_files = ["~/.aws/credentials"]
}

data "aws_caller_identity" "current" {
}

resource "aws_s3_bucket" "helmrepo_bucket" {
  bucket = var.name
  tags   = var.tags
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.helmrepo_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.helmrepo_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.helmrepo_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "helmrepo_log_bucket" {
  bucket = var.helmrepo_log_bucket_name
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.helmrepo_log_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  bucket        = aws_s3_bucket.helmrepo_bucket.id
  target_bucket = aws_s3_bucket.helmrepo_log_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_public_access_block" "no_public_access" {
  bucket                  = aws_s3_bucket.helmrepo_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_s3_bucket.helmrepo_bucket,
    aws_s3_bucket_policy.s3_policy
  ]
}

resource "aws_s3_bucket_public_access_block" "no_public_log_access" {
  bucket                  = aws_s3_bucket.helmrepo_log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_s3_bucket.helmrepo_bucket,
    aws_s3_bucket_policy.s3_policy
  ]
}

data "aws_iam_policy_document" "s3_permissions" {
  dynamic "statement" {
    for_each = var.allowed_account_ids

    content {

      sid       = "Allow cross-account access to list objects (${statement.value})"
      actions   = ["s3:ListBucket"]
      effect    = "Allow"
      resources = [aws_s3_bucket.helmrepo_bucket.arn]

      principals {
        identifiers = ["arn:aws:iam::${statement.value}:root"]
        type        = "AWS"
      }
    }
  }

  dynamic "statement" {
    // Remove accounts with write access from this statement to keep policy size down
    for_each = setsubtract(var.allowed_account_ids, var.allowed_account_ids_write)

    content {
      sid       = "Allow Cross-account read-only access (${statement.value})"
      actions   = ["s3:GetObject*"]
      effect    = "Allow"
      resources = ["${aws_s3_bucket.helmrepo_bucket.arn}/*"]

      principals {
        identifiers = ["arn:aws:iam::${statement.value}:root"]
        type        = "AWS"
      }
    }
  }

  dynamic "statement" {
    for_each = var.allowed_account_ids_write

    content {
      sid = "Allow Cross-account write access (${statement.value})"
      actions = [
        "s3:GetObject*",
        "s3:PutObject*"
      ]
      effect    = "Allow"
      resources = ["${aws_s3_bucket.helmrepo_bucket.arn}/*"]

      principals {
        identifiers = ["arn:aws:iam::${statement.value}:root"]
        type        = "AWS"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.helmrepo_bucket.id
  policy = data.aws_iam_policy_document.s3_permissions.json
}

