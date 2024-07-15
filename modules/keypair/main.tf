# main.tf

variable "key_name" {
  description = "The name for the key pair"
  type        = string
}

variable "public_key" {
  description = "The public key material"
  type        = string
  default     = ""
}

variable "create_private_key" {
  description = "Determines whether to create a private key"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to the key pair"
  type        = map(string)
  default     = {}
}

resource "tls_private_key" "this" {
  count     = var.create_private_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = var.create_private_key ? tls_private_key.this[0].public_key_openssh : var.public_key

  tags = var.tags
}

resource "local_sensitive_file" "private_key" {
  count           = var.create_private_key ? 1 : 0
  content         = tls_private_key.this[0].private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0600"
}

output "key_name" {
  description = "The name of the created key pair"
  value       = aws_key_pair.this.key_name
}

output "key_pair_id" {
  description = "The ID of the created key pair"
  value       = aws_key_pair.this.key_pair_id
}

output "public_key" {
  description = "The public key of the created key pair"
  value       = aws_key_pair.this.public_key
}

output "private_key_pem" {
  description = "The private key in PEM format, if created"
  value       = var.create_private_key ? tls_private_key.this[0].private_key_pem : null
  sensitive   = true
}