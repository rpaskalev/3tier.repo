# variables.tf

variable "region" {
  type = string
  description = "Region name"
  default = "us-west-2"
}

variable "application" {
  type = string
  description = "Applicaiton name"
  default = "toptal3tier"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "myEcsTaskExecutionRole"
}

variable "environment" {
  type = string
  description = "Dev/prod"
  default = "prod"
}

variable "vpc_cidr_prefix" {
  type = string
  description = "Fist two octets of VPC CIDR"
  default = "10.10"
}
variable "vpc_cidr_suffix" {
  type = string
  description = "Last two octets of VPC network and bitmask count"
  default = "0.0/16"
}

variable "root_db_user" {
  type = string
  description = "Root database password"
  default = "root"
}
variable "root_db_password" {
  type = string
  description = "Root database password"
  default = "PrettyStr0ngP4ssrw0rdThisIsnt"
}
variable "db_name" {
  type = string
  description = "Application database name"
  default = "three_tier"
}
variable "db_port" {
  type = string
  description = "Database port"
  default = "5432"
}
variable "backup_retention_period" {
  type = string
  description = "Number of backups to retain (0 to disable)"
  default = "3"
}
variable "rds_multi_az" {
  type = string
  description = "Is this database multi-availability-zone or not?"
  default = "true"
}
variable "rds_instance_class" {
  type = string
  description = "Independently configure server class/size"
  default = "db.t3.small"
}
variable "rds_encrypted" {
  type = string
  description = "Is the database encrypted at rest?"
  default = "false"
}

variable "container_registry" {
  description = "Docker container registry"
  default     = "mgstoptal"
}

variable "api_image" {
  description = "Docker image to run in the API container in ECS cluster"
  default     = "toptal3tier-api"
}

variable "web_image" {
  description = "Docker image to run in the WEB container in ECS cluster"
  default     = "toptal3tier-web"
}

variable "container_tag" {
  description = "The tag of the docker image to be deployed"
  default     = "a72e60"
}

variable "api_port" {
  description = "Port exposed by the API docker image to redirect traffic to"
  default     = 3000
}

variable "web_port" {
  description = "Port exposed by the WEB docker image to redirect traffic to"
  default     = 3000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 2
}

variable "ecs_autoscale_min_instances" {
  default = "2"
}

variable "ecs_autoscale_max_instances" {
  default = "3"
}

variable "ecs_as_cpu_low_threshold_per" {
  description = "The average CPU utilization over a minute for downscale"
  default = "20"
}

variable "ecs_as_cpu_high_threshold_per" {
  description = "The average CPU utilization over a minute for upscale"
  default = "80"
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = 256
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = 512
}