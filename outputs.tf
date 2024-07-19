# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}


output "vpc_flow_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs"
  value       = module.vpc.flow_log_group_name
}

# Security Group Outputs
output "web_server_sg_id" {
  description = "The ID of the web server security group"
  value       = module.sg.security_group_id
}

output "web_server_sg_name" {
  description = "The name of the web server security group"
  value       = module.sg.security_group_name
}

# EC2 Key Pair Outputs
output "key_pair_name" {
  description = "The name of the created key pair"
  value       = module.ec2_key_pair.key_name
}

output "private_key_pem" {
  description = "The private key in PEM format"
  value       = module.ec2_key_pair.private_key_pem
  sensitive   = true
}

# Web Server EC2 Instance Outputs
output "web_server_instance_id" {
  description = "The ID of the web server EC2 instance"
  value       = module.web_server.instance_id
}

output "web_server_private_ip" {
  description = "The private IP of the web server EC2 instance"
  value       = module.web_server.private_ip
}

# Bastion Host EC2 Instance Outputs
output "bastion_host_instance_id" {
  description = "The ID of the bastion host EC2 instance"
  value       = module.bastion_host.instance_id
}

output "bastion_host_public_ip" {
  description = "The public IP of the bastion host EC2 instance"
  value       = module.bastion_host.public_ip
}

output "bastion_host_private_ip" {
  description = "The private IP of the bastion host EC2 instance"
  value       = module.bastion_host.private_ip
}