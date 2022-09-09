# Main.tf Script

# who is the cloud provider 
# it's aws
# init and download required packges 
# terraform init

# create a block of code to launch ec2-server

# which resources do we like to create

provider "aws" {
    region = "eu-west-1"

}

# VPC / / Internet Gateway / Subnets -- Generation

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    tags = {
      Name = "eng122-haider-vpc-tf"
    } 
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "eng122-haider-tf-igw"
  }
}

# Public & Private Subnet Creation

resource "aws_subnet" "eng122-haider-pub-tf" {
    cidr_block = "10.0.9.0/24"
    map_public_ip_on_launch = "true"
    
    tags = {
        Name = "eng122-haider-pub-tf"
    }
}

resource "aws_subnet" "eng122-haider-priv-tf" {
    vpc_id = awc_vpc.main.id
    cidr_block = "10.0.18.0/24"
    map_public_ip_on_launch = "false"
    
    tags = {
        Name = "eng122-haider-priv-tf"
    }
}

# Creating Route Table for Public & Private subnet 

resource "aws_route_table" "eng122-haider-crt-pub" {
    vpc_id = aws_vpc.main.id
    
    route {
        # associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.igw.id 
    }
    
    tags = {
        Name = "eng122-haider-crt-pub"
    }
 
}

resource "aws_route_table" "eng122-haider-crt-priv" {
    vpc_id = aws_vpc.main.id
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.igw.id 
    }
    
    tags = {
        Name = "eng122-haider-crt-priv"
    }
}
# Associating CRT with Public & Private

resource "aws_route_table_association" "eng122-haider-crt-pub"{
    subnet_id = aws_subnet.eng122-haider-pub-tf.id
    route_table_id = aws_route_table.eng122-haider-crt-pub.id
}

resource "aws_route_table_association" "eng122-haider-crt-private"{
    subnet_id = aws_subnet.eng122-haider-priv-tf.id
    route_table_id = aws_route_table.eng122-haider-crt-priv.id 
}

# Creating Security Group Rules for Incoming and Outgoing Traffic
resource "aws_security_group" "app_sg" {
  name        = "eng122-haider-tf-sg"
  description = "Security Generated on Terraform"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launching of EC2 Instance
resource "aws_instance" "node-app" {
  
# using which ami
    ami = "ami-0c31b3fe91357577c"

# instance type
    instance_type = "t2.micro"

# Specifying key name created in AWS
    key_name = "eng122-haider"
      
# do we need it to have public ip
    associate_public_ip_address = true 

    subnet_id = aws_subnet.eng122-haider-pub-tf.id

# how to name your instance
    tags = {
      Name = "eng122-haider-terraform-app"
    }
    
}
# Deploying Public Key
resource "aws_key_pair" "deployer" {
  key_name   = "eng122-haider"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIHrnDKZBq3muDZLBwfsuUXTM9xXYo/uSfP9rGJU5JDx haide@Hades-PC"
 
}