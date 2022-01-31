resource "aws_key_pair" "ssh-key" {
  key_name   = var.name
  public_key = file("${var.key_path}")
}