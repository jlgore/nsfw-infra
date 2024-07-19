# test/main_test.tftest.hcl

# Define variables that match your main.tf
variables {
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  enable_flow_log = true
  flow_log_retention_in_days = 30
}

# Test the entire configuration
run "verify_ec2_instances" {
  command = plan

  # Verify web server instance
  assert {
    condition     = module.web_server.instance_type == "t2.micro"
    error_message = "Web server instance type is not t2.micro"
  }

  assert {
    condition     = module.web_server.subnet_id == module.vpc.private_subnet_ids[0]
    error_message = "Web server is not in the first private subnet"
  }

  assert {
    condition     = contains(module.web_server.vpc_security_group_ids, module.sg.security_group_id)
    error_message = "Web server does not have the correct security group"
  }

  assert {
    condition     = module.web_server.key_name == module.ec2_key_pair.key_name
    error_message = "Web server does not have the correct key pair"
  }

  assert {
    condition     = module.web_server.associate_public_ip_address == false
    error_message = "Web server should not have a public IP address"
  }

  # Verify bastion host instance
  assert {
    condition     = module.bastion_host.instance_type == "t2.micro"
    error_message = "Bastion host instance type is not t2.micro"
  }

  assert {
    condition     = module.bastion_host.subnet_id == module.vpc.public_subnet_ids[1]
    error_message = "Bastion host is not in the second public subnet"
  }

  assert {
    condition     = contains(module.bastion_host.vpc_security_group_ids, module.sg.security_group_id)
    error_message = "Bastion host does not have the correct security group"
  }

  assert {
    condition     = module.bastion_host.key_name == module.ec2_key_pair.key_name
    error_message = "Bastion host does not have the correct key pair"
  }

  assert {
    condition     = module.bastion_host.associate_public_ip_address == true
    error_message = "Bastion host should have a public IP address"
  }
}

# Test VPC configuration
run "verify_vpc" {
  command = plan

  assert {
    condition     = module.vpc.vpc_cidr_block == var.vpc_cidr
    error_message = "VPC CIDR block does not match input"
  }

  assert {
    condition     = length(module.vpc.public_subnet_ids) == length(var.public_subnet_cidrs)
    error_message = "Number of public subnets does not match input"
  }

  assert {
    condition     = length(module.vpc.private_subnet_ids) == length(var.private_subnet_cidrs)
    error_message = "Number of private subnets does not match input"
  }
}

# Test security group configuration
run "verify_security_group" {
  command = plan

  assert {
    condition     = module.sg.security_group_name == "web-server-sg"
    error_message = "Security group name is incorrect"
  }

  assert {
    condition     = length(module.sg.security_group_ingress_rules) == 3
    error_message = "Incorrect number of ingress rules in security group"
  }
}
