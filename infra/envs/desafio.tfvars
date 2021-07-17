## Terraform
bucket = "gama-academy-terraform-state"
terraform_key = "terraform.tfstate"
aws_region = "us-east-1"

## Cluster
cluster_name = "desafio"
vpc_id = "vpc-2e0b6c53"

## Load Balancer
lb_name = "desafio-lb"

##Task definitions
subnets_list = ["subnet-0cf1ea41", "subnet-d56d3cf4"]
ecs_task_execution_role_name = "DesafioEcsTaskExecutionRole"

## app
app_name = "app"
app_port = 3000
app_tg_protocol = "HTTP"
app_health_check_path = "/"
app_fargate_cpu = 256
app_fargate_memory = 512
app_min_capacity = 1
app_count = 1
app_max_capacity = 2
app_ecr_repo_name = "desafio/app"
