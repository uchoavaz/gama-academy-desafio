# variables.tf

variable "cluster_name" {
  description = "Cluster name"
}

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "myEcsTaskExecutionRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "health_check_path" {
  default = "/"
}



variable "subnets_list" {
  description = "Subnets to run tasks)"
  type    = list(string)
}

variable "lb_name" {
  description = "Load Balancer Name"
}

variable "vpc_id" {
  description = "VPC Id"
}


## APP

variable "app_tg_protocol" {
  description = "Target group protocol"
  default     = "HTTPS"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 3
}

variable "app_fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "app_fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "app_min_capacity" {
  description = "app app auto scale min capacity"
}
variable "app_max_capacity" {
  description = "app app auto scale max capacity"
}

variable "app_ecr_repo_name" {
  description = "app App Ecr repository name"
}

variable "app_health_check_path" {
  default = "/"
}

variable "app_name" {
  description = "App name"

}

variable "bucket" {
  description = "Terraform state bucket"

}

variable "terraform_key" {
  description = "Terraform Key"

}