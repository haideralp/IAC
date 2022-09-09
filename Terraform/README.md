# Terraform - Orchestration

## Diagram Showing Using Terraform for Multi-Cloud Deployment

![image](https://user-images.githubusercontent.com/97620055/189123364-ee2d3e4a-4bfc-4ebd-9b5a-35482c4b830b.png)

## What is Terraform ?

- It is an IAC tool, used primarily by DevOps teams to automate various infrastructure tasks. The provisioning of cloud resources, for instance, is one of the main use cases of Terraform. It’s a cloud-agnostic (compatability with multiple cloud provider), open-source provisioning tool written in the Go language and created by HashiCorp (uses HCL).

## Benefits of Terraform ?

- Speed and Simplicit --> eliminates manual processes, so delivery and management lifecycles. IaC makes it possible to spin up an entire infrastructure architecture by simply running a script.
- Team Collaboration --> team members can collaborate on IaC software in the same way they would with regular application code through tools like Github. Code can be easily linked to issue tracking systems for future use and reference.
- Error Reduction -->  minimizes the probability of errors or deviations when creating. Reusable code, allows applications to run smoothly and error-free without the constant need for admin oversight.
- Disaster Recovery --> With IaC you can actually recover from disasters more rapidly. Because manually constructed infrastructure needs to be manually rebuilt. But with IaC, you can usually just re-run scripts and have the exact same software provisioned again.
- Enhanced Security --> removes many security risks associated with human error as correct set up of IT infrastructure. 

## Why use Terraform to manage your Infrastructure ?

- Terraform is an orchestrator and not an automation tool - automation focuses single task orchestration involves creating workflow and combining them. 

- It follows a declarative approach and not a procedural - you tell tool what needs to be done and not how as it will self-manage this. 

- Cloud Agnostic platform - has multiple support for various cloud providers like GCP, AWS and Azure. 


## Installting Terraform

- For Windows follow guidlines on this link after open windows power shell in startup menu as **admin**.

## Terraform Key Commands

## Create Terraform Script

- Creat a main.tf script in relevant directory.
- In same directory perform the following commands in order
    - `terraform plan` - writes a plan and checks tf script for errors
    - `terraform apply` - applys the script to cloud
    - `terraform destroy` - destroys the services created from tf script.
  
## Launching EC2 Instance with Configured: VPC,Subnets,Internet Gateway,Route Tables:

- Perform the steps below in **main.tf** in order to successfuly launch of EC2 instance with configured network settings:
    1. Create VPC 
    2. Create public (app) and private (db) subnets within vpc. Used: `10.0.9.0/24 / 10.0.18.0/24` respectively.
    3. Interent gateway must be provisioned witin VPC. 
    4. Routes tables for both subnets must be created.
    5. Association for subnets the route tables must be performed.
    6. Create security groups for ingress and egress routes. 
    7. Create the EC2 instance within the VPC. 
 ## Abstraction Performed In Terraform

- To minimise displaying any potential data, refactor the main.tf script by creating a new `variable.tf script` defining all the key parameters so only necessary information is displayed. The variable script must be added `.gitignore` file.

### Main.tf (refactored with var)
   

``` python
provider "aws" {
    region = "eu-west-1"

}

# VPC / / Internet Gateway / Subnets -- Generation

resource "aws_vpc" "main" {
    cidr_block = var.awc_vpc
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
    cidr_block = var.aws_public_subnet
    map_public_ip_on_launch = "true"
    
    tags = {
        Name = "eng122-haider-pub-tf"
    }
}

resource "aws_subnet" "eng122-haider-priv-tf" {
    vpc_id = awc_vpc.main.id
    cidr_block = var.aws_private_subnet
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
    ami = var.ami_id

# instance type
    instance_type = "t2.micro"

# Specifying key name created in AWS
    key_name = var.aws_key_name
      
# do we need it to have public ip
    associate_public_ip_address = true 

    subnet_id = aws_subnet.eng122-haider-pub-tf.id

# how to name your instance
    tags = {
      Name = "eng122-haider-terraform-app"
    }
    
}
```
