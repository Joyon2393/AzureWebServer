# AzureWebServer

Introduction

For this project we wrote a packer template and a terraform template to deploy a webserver in azure. 

Getting Started

Clone the repositiory: https://github.com/Joyon2393/AzureWebServer.git

Dependencies

1. Install latest version of terraform
2. Install latest version of Packer
3. Visual Studio code
4. Create azure account

Instruction
Packer
#From azure CLI create a resource group to hold packer image. 
az group create -n myPackerImage -l eastus //provide a resource group name of choosing
#Run below command to get necessary information for packer template
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<subscription_id> --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
ref: learn.microsoft.com
#make note of client_id, client_secret, tenant_id. 

Create packer template server.json
update client_id, client_secret, tenant_id from above step. 

Run packer build server.json

Web Server

In var.tf file update default value of #packer_resource_group_name=name of the resource group where packer image created
#packer_image_name=name of the packer image
#number_of_VM=number of vm created (2-5)
#admin_user: provide a username
#admin_password= must follow password policy of Microsoft i.e Minimum 8 to 12 digit with upper and lowercase letter, numebr and special charecter. 

Run Terraform init
Run terraform plan -out solution.plan
Terraform will ask to provide value of different variables. In the discription field it will inform what value it expects. 

Run terraform apply "solution.plan"

Output

terrform will create following resourses:
        1. Resource group
        2. Virtual network
        3. subnet
        4. Network security group
        5. Security policy
        6. Network interface
        7. Load balancer
        8. Public IP
        9. Availibility set
        10. Virtual machine with packer image








