provider "aws" {
  region     = "eu-west-2"
}
resource "aws_vpc" "this" {
  cidr_block = "10.20.20.0/25"
  tags = {
    "Name" = "Application-1"
  }
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.20.20.0/26"
  availability_zone = "eu-west-2a"
}
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.20.20.64/26"
  availability_zone = "eu-west-2a"
}
resource "aws_route_table" "this-rt" {
  vpc_id = aws_vpc.this.id
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.this-rt.id
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.this-rt.id
}
resource "aws_internet_gateway" "this-igw" {
  vpc_id = aws_vpc.this.id

}
resource "aws_route" "internet-route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.this-rt.id
  gateway_id             = aws_internet_gateway.this-igw.id
}
resource "aws_network_interface" "this-nic" {
  subnet_id       = aws_subnet.public.id
  private_ips     = [var.private_ip_address]
  security_groups = [aws_security_group.web-pub-sg.id]
}

resource "aws_eip" "ip-one" {
  vpc                       = true
  network_interface         = aws_network_interface.this-nic.id
  depends_on                = [aws_instance.app-server]
}

resource "aws_security_group" "web-pub-sg" {
  name        = "${var.aws_security_group}"                ### Survey
  description = "allow inbound traffic"
  vpc_id      = aws_vpc.this.id
  ingress {
    description = "from my ip range"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    to_port     = "0"
  }
}
resource "aws_instance" "app-server" {
  instance_type = "${var.instance_type}"
  ami           = "ami-08d9bb4bfe39be5c2"
  network_interface {
    network_interface_id = aws_network_interface.this-nic.id
    device_index         = 0
delete_on_termination = false
  }
  key_name = "controller_ssh"
  tags = {
      Name = "${var.instance_name}"
      }
}
