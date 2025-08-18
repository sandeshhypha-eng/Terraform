resource "aws_instance" "app" {
  ami           = "ami-08f63db601b82ff5f"
  instance_type = "t2.micro"

  tags = {
    Name        = "${var.project_name}-${var.env}-ec2"
    Environment = var.env
  }
}
