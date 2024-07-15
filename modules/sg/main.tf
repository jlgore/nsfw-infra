# main.tf

variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
  default     = "Security group managed by Terraform"
}

variable "vpc_id" {
  description = "ID of the VPC where to create the security group"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules to create"
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules to create"
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))
  default = [{
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }]
}

variable "tags" {
  description = "A map of tags to add to the security group"
  type        = map(string)
  default     = {}
}

resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress_rules)

  type              = "ingress"
  description       = var.ingress_rules[count.index].description
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = var.ingress_rules[count.index].cidr_blocks
  ipv6_cidr_blocks  = var.ingress_rules[count.index].ipv6_cidr_blocks
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  count = length(var.egress_rules)

  type              = "egress"
  description       = var.egress_rules[count.index].description
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  protocol          = var.egress_rules[count.index].protocol
  cidr_blocks       = var.egress_rules[count.index].cidr_blocks
  ipv6_cidr_blocks  = var.egress_rules[count.index].ipv6_cidr_blocks
  security_group_id = aws_security_group.this.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.this.id
}

output "security_group_arn" {
  description = "The ARN of the security group"
  value       = aws_security_group.this.arn
}

output "security_group_name" {
  description = "The name of the security group"
  value       = aws_security_group.this.name
}