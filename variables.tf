
variable "region" {
  type        = string
  description = "the name of the region you wish to deploy into"
  default     = "us-east-1"
}

variable "name" {
  description = "Name given resources"
  type        = string
  default     = "aws-quickstart"
}

variable "service_name" {
  type        = string
  default     = "nginx"
  description = "A name for the service"
}

variable "image_url" {
  type        = string
  default     = "nginx"
  description = "the url of a docker image that contains the application process that will handle the traffic for this service"
}

variable "container_port" {
  type        = number
  default     = 80
  description = "What port number the application inside the docker container is binding to"
}

variable "container_cpu" {
  type        = number
  default     = 256
  description = "How much CPU to give the container. 1024 is 1 CPU"
}

variable "container_memory" {
  type        = number
  default     = 512
  description = "How much memory in megabytes to give the container"
}

variable "lb_path" {
  type        = string
  default     = "*"
  description = "A path on the public load balancer that this service should be connected to. Use * to send all load balancer traffic to this service."
}

variable "routing_priority" {
  type        = number
  default     = 1
  description = "The priority for the routing rule added to the load balancer. This only applies if your have multiple services which have been assigned to different paths on the load balancer."
}

variable "desired_count" {
  type        = number
  default     = 2
  description = "How many copies of the service task to run"
}