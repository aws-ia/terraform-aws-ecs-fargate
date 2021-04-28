**Terraform AWS ECS Fargate Module**

Authors: David Wright (dwright@hashicorp.com) and Tony Vattahil (tonynv@amazon.com)

This Terraform module deploys Amazon Elastic Container Service (Amazon ECS) on AWS Fargate. It deploys a public facing, privately-networked Fargate service with a private subnet in an Amazon Virtual Private Cloud (VPC) to run your application containers. In this architecture, containers do not have direct internet access or a public IP address, only a private IP address internal to the VPC. Outbound connections from the containers are routed through a NAT gateway in the public subnet of the VPC. Only the IP address of the NAT gateway is seen by recipients of container requests. A public-facing load balancer accepts inbound connections on specific ports, and forwards acceptable traffic to containers inside the private subnet.

To deploy the Terraform Amazon Transit Gateway module, do the following:

Install Terraform. For instructions and a video tutorial, see Install Terraform.
Sign up and log into Terraform Cloud. (There is a free tier available.)
Configure Terraform Cloud API access. Run the following to generate a Terraform Cloud token from the command line interface:
terraform login
Export TERRAFORM_CONFIG
export TERRAFORM_CONFIG="$HOME/.terraform.d/credentials.tfrc.json"
Configure the AWS Command Line Interface (AWS CLI). For more information, see Configuring the AWS CLI.

If you don't have git installed, install git.

Clone this aws-quickstart/terraform-aws-transit-gateway repository using the following command:

git clone https://github.com/aws-quickstart/terraform-aws-ecs-fargate

Change directory to the root repository directory.

cd /terraform-aws-ecs-fargate/

Change to the deploy directory.

cd setup_workspace.
To perform operations locally, do the following:

a. Initialize the deploy directory. Run terraform init.
b. Start a Terraform run using the configuration files in your deploy directory. Run terraform apply or terraform apply -var-file="$HOME/.aws/terraform.tfvars".

Change to the deploy directory with cd ../deploy.

Run terraform init.

Run terraform apply or terraform apply -var-file="$HOME/.aws/terraform.tfvars". Terraform apply is run remotely in Terraform Cloud.
