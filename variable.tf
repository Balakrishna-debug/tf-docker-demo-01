variable "instance_count" {
    default = 1
  }
variable "region" {
  description = "AWS region for hosting our your network"
  default = "eu-north-1"
}
variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default = "/home/ratul/developments/devops/keyfile/ec2-core-app.pem"
}
variable "key_name" {
  description = "Key name for SSHing into EC2"
  default = "ec2-core-app"
}
variable "amis" {
  description = "Base AMI to launch the instances"
  default = {
  eu-north-1 = "ami-04b54ebf295fe01d7"
  }
}