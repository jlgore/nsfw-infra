# main.tf

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "my-ec2-instance"
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the key pair to use for SSH access"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Size of the root volume in gigabytes"
  type        = number
  default     = 8
}

variable "tags" {
  description = "A map of tags to add to the instance"
  type        = map(string)
  default     = {}
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "this" {
  ami           = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = var.vpc_security_group_ids
  key_name               = var.key_name

  associate_public_ip_address = var.associate_public_ip_address

  root_block_device {
    volume_type = "gp2"
    volume_size = var.root_volume_size
  }

  tags = merge(
    {
      "Name" = var.instance_name
    },
    var.tags
  )
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address of the EC2 instance (if associated)"
  value       = aws_instance.this.public_ip
}