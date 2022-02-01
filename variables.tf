#---------------------------------------------------
# Create General Variables
#---------------------------------------------------

variable "region" {
  description = "AWS region"
  default = "us-east-2"
  type        = string
}
variable "project" {
  type = string
  default = "demo3"
}

variable "env" {
  description = "The environment of the project(Dev,Test,Prod)"
  default     = "test"
}
variable "app" {
  description = "The Name of the project"
  default     = "starwars"
}
#---------------------------------------------------
# Create Network Variables
#---------------------------------------------------

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "pubsubnet_cidr" {
  default = [
    "10.0.11.0/24" ,
    "10.0.21.0/24"
  ]
}
variable "privsubnet_cidr" {
  default = [
    "10.0.12.0/24" ,
    "10.0.22.0/24"
  ]
}

#---------------------------------------------------
# Create Variables for Application Load Balancer
#---------------------------------------------------
variable "app_port" {
  description = "The application port"
  default     = 80
}

variable "app_target_port" {
  description = "The application port"
  default     = 80
}

variable "health_check_path" {
  description = "The path for health check web servers"
  default     = "/"
}
#---------------------------------------------------
# Create Variables for for ECR
#---------------------------------------------------

variable "name_container" {
  description = "The container name"
  default     = "nginx"
}
#---------------------------------------------------
# Create Variables for for ECS
#---------------------------------------------------

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

variable "web_server_image" {
  description = "The web server image to run in the ECS cluster"
  default     = "447854022972.dkr.ecr.us-east-2.amazonaws.com/my_app-test-nginx"
}
#  717838986976.dkr.ecr.eu-central-1.amazonaws.com/my-first-image

variable "web_server_count" {
  description = "Number of web server containers to run"
  default     = 1
}

variable "websrv_fargate_cpu" {
  description = "Fargate instance CPU units to provision for web server (1 vCPU = 1024 CPU units)"
  default     = 256
}

variable "websrv_fargate_memory" {
  description = "Fargate instance memory to provision for web server (in MiB)"
  default     = 512
}
