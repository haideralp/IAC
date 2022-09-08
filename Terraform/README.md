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

## Create Terraform Script

- Creat a main.tf script in relevant directory.
- In same directory perform 
