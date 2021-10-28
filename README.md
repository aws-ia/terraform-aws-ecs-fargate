> Note: This module is in alpha state and is likely to contain bugs and updates may introduce breaking changes. It is not recommended for production use at this time.
# Terraform AWS ECS Fargate
Authors: David Wright (dwright@hashicorp.com) and Tony Vattahil (tonynv@amazon.com)

To deploy the Terraform Amazon Fargate module, do the following:

1. Install Terraform. For instructions and a video tutorial, see [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli). 

2. Sign up and log into Terraform Cloud. (There is a free tier available.)

3. Configure Terraform Cloud API access. Run the following to generate a Terraform Cloud token from the command line interface:
```
terraform login

--For Mac/Linux
export TERRAFORM_CONFIG="$HOME/.terraform.d/credentials.tfrc.json"

--For Windows
export TERRAFORM_CONFIG="$HOME/AppData/Roaming/terraform.d/credentials.tfrc.json"
```

4. Configure the AWS Command Line Interface (AWS CLI). For more information, see [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

5. If you don't have git installed, [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git). 

6. Clone this **aws-ia/terraform-aws-ecs-fargate** repository using the following command:

   `git clone https://github.com/aws-ia/terraform-aws-ecs-fargate.git`

7. Change directory to the root repository directory.

   `cd terraform-aws-ecs-fargate/`

8. For setting up a new terraform workspace:
   
      - `cd setup_workspace`
      - `terraform init`
      - `terraform apply`

9. To create new VPC and deploy Fargate module:
      - Change to the deploy directory. Run `cd ../deploy`
      - Initialize the deploy directory. Run `terraform init`.
      - Start a Terraform run using the configuration files in your deploy directory. Run `terraform apply`  or `terraform apply -var-file="$HOME/.aws/terraform.tfvars"` (Note: The deployment is remotely run in Terraform Cloud)
   
   For existing VPC pass `vpc_id` directly to the Fargate module.

## Amazon ECS Exec 
This module supports [Amazon ECS Exec](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html). It can be enabled by setting the `enable_ecs_exec` variable to true.

You can exec to the running container by running the following command:
```shell
aws ecs execute-command --cluster cluster-name \
    --task task-id \
    --container container-name \
    --interactive \
    --command "/bin/sh"
    --profile your-profile
```
