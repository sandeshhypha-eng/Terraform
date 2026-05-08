resource "aws_instance" "demo_ec2" {
  ami           = var.ami
  instance_type = var.instance_type

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [tags]
  }

  tags = {
    Name = var.tag1
  }
}

output "instance_id" {
  value = aws_instance.demo_ec2.id
}

output "instance_public_ip" {
  value = aws_instance.demo_ec2.public_ip
}