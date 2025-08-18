resource "aws_s3_bucket" "bucket" {
  bucket = "${var.project_name}-${var.env}-bucket"

  tags = {
    Name        = "${var.project_name}-${var.env}-bucket"
    Environment = var.env
  }
}
