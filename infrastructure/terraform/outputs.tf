output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.poc3_vpc.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private_subnets[*].id
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.poc3_cluster.name
}

output "ecs_cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.poc3_cluster.arn
}

output "ecr_repository_urls" {
  description = "ECR Repository URLs"
  value       = { for i, repo in aws_ecr_repository.app_repos : var.ecr_repositories[i] => repo.repository_url }
}

output "load_balancer_dns" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.poc3_alb.dns_name
}

output "load_balancer_zone_id" {
  description = "Application Load Balancer Zone ID"
  value       = aws_lb.poc3_alb.zone_id
}

output "s3_bucket_name" {
  description = "S3 Artifacts bucket name"
  value       = aws_s3_bucket.artifacts_bucket.bucket
}

output "s3_bucket_arn" {
  description = "S3 Artifacts bucket ARN"
  value       = aws_s3_bucket.artifacts_bucket.arn
}

output "ecs_task_execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ECS Task Role ARN"
  value       = aws_iam_role.ecs_task_role.arn
}

output "target_group_arns" {
  description = "Target Group ARNs"
  value       = { for i, tg in aws_lb_target_group.app_tg : var.ecr_repositories[i] => tg.arn }
}

output "security_group_ids" {
  description = "Security Group IDs"
  value = {
    alb = aws_security_group.alb_sg.id
    ecs = aws_security_group.ecs_sg.id
  }
}