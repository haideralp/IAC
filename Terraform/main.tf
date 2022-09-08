# Main.tf Script

# who is the cloud provider 
# it's aws
provider "aws" {

# within that cloud which part of world 
# we want to to use eu-west-1   
    region = "eu-west-1"

}

# init and download required packges 
# terraform init

# create a block of code to launch ec2-server

# which resources do we like to create
resource "aws_instance" "node_app" {
  
# using which ami
    ami = "ami-0b47105e3d7fc023e"

# instance type
    instance_type = "t2.micro"

# do we need it to have public ip
    associate_public_ip_address = true 

# Attaching key
    key_name = "eng122-haider.pem"

# Specifiying SSH conncetion to private key

    connection {
      type        = "ssh"
      host        = self.associate_public_ip_address
      user        = "ubuntu"
      private_key = file("/c/Users/haide/.ssh/eng122-haider.pem")
      timeout     = "4m"
   }


# how to name your instance
    tags = {
      Name = "eng122-haider-terraform-app"
    }
}

# find out how to attach your file.pem