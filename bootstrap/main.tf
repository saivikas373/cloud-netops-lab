resource "aws_s3_bucket" "tfstate" {
    bucket = "cloud-netops-lab-tfstate-440890470739"

    lifecycle {
        prevent_destroy = true
    } 
    
}

resource "aws_s3_bucket_versioning" "tfstate" {
    bucket = aws_s3_bucket.tfstate.id 

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
    bucket = aws_s3_bucket.tfstate.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
} 