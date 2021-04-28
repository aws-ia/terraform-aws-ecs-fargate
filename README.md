#################################################################
# This module will create A Public Exposed Fargate Service with Private Networking
#
# This architecture deploys your container into a private subnet. 
# The containers do not have direct internet access, or a public IP address.
# Their outbound traffic must go out via a NAT gateway, and receipients of 
# requests from the containers will just see the request orginating from 
# the IP address of the NAT gateway. However, inbound traffic from the public
# can still reach the containers because there is a public facing load balancer
# that can proxy traffic from the public to the containers in the private subnet.
#################################################################


![private subnet public load balancer](images/private-task-public-loadbalancer.png)

Authors: David Wright (dwright@hashicorp.com) and Tony Vattahil (tonynv@amazon.com)

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
