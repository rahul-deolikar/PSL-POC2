variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "poc3"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "poc3"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for ECS cluster"
  type        = string
  default     = "t3.medium"
}

variable "min_capacity" {
  description = "Minimum number of instances in the ECS cluster"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of instances in the ECS cluster"
  type        = number
  default     = 5
}

variable "desired_capacity" {
  description = "Desired number of instances in the ECS cluster"
  type        = number
  default     = 2
}

variable "key_pair_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "poc3-keypair"
}

variable "ecr_repositories" {
  description = "List of ECR repository names"
  type        = list(string)
  default     = [
    "poc3-nodejs-api",
    "poc3-reactjs-frontend",
    "poc3-dotnet-api",
    "poc3-java-api",
    "poc3-python-api"
  ]
}

variable "s3_bucket_name" {
  description = "S3 bucket name for artifacts"
  type        = string
  default     = "poc3-artifacts-bucket"
}

variable "enable_fargate" {
  description = "Enable Fargate capacity provider"
  type        = bool
  default     = true
}

variable "enable_ec2" {
  description = "Enable EC2 capacity provider"
  type        = bool
  default     = true
}