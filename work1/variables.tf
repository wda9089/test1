variable "aws_security_group" {
  default = "provder_test" # AWS Security Group name
}
variable "instance_name" {
  default = "Provider_ec2" # AWS Name of instance
}
variable "instance_type" {
  default = "t2.micro" # AWS Instance type
}
variable "private_ip_address" {
  type    = string
  default = "10.20.20.121"
}
