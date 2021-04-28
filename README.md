**Terraform AWS ECS Fargate Module**

Authors: David Wright (dwright@hashicorp.com) and Tony Vattahil (tonynv@amazon.com)

This Terraform module deploys a public Amazon Web Services (AWS) Fargate service with private networking on the AWS Cloud. It deploys a virtual private cloud (VPC) with public and private subnets, according to AWS best practices, to provide you with your own virtual network on AWS. Application containers run in the private subnet of the VPC. Containers do not have direct internet access or a public IP address, only a private IP address internal to the VPC. Outbound connections from the containers are routed through a NAT gateway in the public subnet of the VPC. Only the IP address of the NAT gateway is seen by recipients of container requests. A public load balancer accepts inbound connections on specific ports, and forwards acceptable traffic to containers inside the private subnet.

To deploy the Terraform Amazon Transit Gateway module, do the following:

1. Install Terraform. For instructions and a video tutorial, see [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli). 
2. Sign up and log into Terraform Cloud. (There is a free tier available.)
3. Configure Terraform Cloud API access. Run the following to generate a Terraform Cloud token from the command line interface:
```
terraform login
Export TERRAFORM_CONFIG
export TERRAFORM_CONFIG="$HOME/.terraform.d/credentials.tfrc.json"
```

3. Configure the AWS Command Line Interface (AWS CLI). For more information, see [Configuring the AWS CLI](https://doc.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).
4. If you don't have git installed, [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git). 
5. Clone this **aws-quickstart/terraform-aws-ecs-fargate** repository using the following command:

   `git clone https://github.com/aws-quickstart/terraform-aws-ecs-fargate`

6. Change directory to the root repository directory.

   `cd /terraform-aws-ecs-fargate/`

7. Change to the deploy directory.

   - `cd setup_workspace`. 

8. To perform operations locally, do the following: 
   
   a. Initialize the deploy directory. Run `terraform init`.  
   b. Start a Terraform run using the configuration files in your deploy directory. Run `terraform apply` or `terraform apply  -var-file="$HOME/.aws/terraform.tfvars"`.
 
9. Change to the deploy directory with `cd ../deploy`.
10. Run `terraform init`.
11. Run `terraform apply` or `terraform apply  -var-file="$HOME/.aws/terraform.tfvars"`. `Terraform apply` is run remotely in Terraform Cloud.
