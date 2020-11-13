# terraform-aws
Terraform to create, manage, and update infrastructure resources on Cloud - AWS

Below are the steps to be followed for this deployment

#Create VPC

#Create Internet Gateway

#Create Custom Route table

#Create a subnet

#Associate subnet with route table

#Create secuity group to allow communication over ports - 443, 80 and 22

#Create a network interface with an IP in the subnet that was created as per earlier step

#Assign an Elastic IP to the network interface created in the previous step

#Create an Ubuntu server and install/configure Apache web server

Below are the commands which were used for provisioning resources.

terraform init
terraform plan
terraform apply
terraform apply — auto-approve

terraform state list
terraform state show xxxxxxxxx

terraform apply -target <resource_name>
terraform apply -var “variable name=value”
terraform apply -var-file “xxxxxx.tfvars”

terraform output
terraform refresh

terraform destroy
terraform destroy -target <resource_name>

terraform workspaces new <Environment Name>


Terraform Provider resources info:

https://www.terraform.io/docs/providers/index.html

https://registry.terraform.io/providers/hashicorp/aws/latest/docs

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
