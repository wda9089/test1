provider "aws" {
  region     = "eu-west-2"
}

resource "aws_instance" "app-server" {
  instance_type = "${var.instance_type}"
  ami           = "ami-08d9bb4bfe39be5c2" 
  key_name = "test1"
  vpc_security_group_ids = "${var.aws_security_group}"
  tags = {
      Name = "${var.instance_name}"
      }
}
