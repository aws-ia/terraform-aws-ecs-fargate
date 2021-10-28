## Backend configuration
This example uses [Terraform Cloud](https://www.terraform.io/docs/language/settings/backends/remote.html). For testing purposes it is possible to override this configuration using a `override.tf` file as described [here](https://www.terraform.io/docs/language/files/override.html).

## Allowing egress traffic
The default image `nginx` requires egress traffic in order to pull the Docker image. You will need to allow this by overriding the `remote_cidr_blocks` variable.

