
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["us-west-2a", "us-west-2b"]
  enable_flow_log      = true
  flow_log_retention_in_days = 30
}

module "sg" {
  source = "./modules/sg"

  name        = "web-server-sg"
  description = "Security group for web servers"
  vpc_id      = module.vpc.vpc_id  # Assuming you're using the VPC module from earlier

  ingress_rules = [
    {
      description      = "Allow HTTP from anywhere"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    },
    {
      description      = "Allow HTTPS from anywhere"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    },
    {
      description      = "Allow SSH from internal network"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
    }
  ]

  # The default egress rule (allow all outbound traffic) will be applied

  tags = {
    Environment = "dev"
    Project     = "nsfwctl"
  }
}

module "ec2_key_pair" {
  source = "./modules/keypair"

  key_name           = "my-new-key"
  create_private_key = true

  tags = {
    Environment = "dev"
    Project     = "nsfwctl"
  }
}

module "web_server" {
  source = "./modules/ec2"

  instance_name    = "web-server"
  instance_type    = "t2.micro"
  subnet_id        = module.vpc.public_subnet_ids[0]  # Assuming you're using the VPC module from earlier
  vpc_security_group_ids = [module.sg.security_group_id]  # You'd need to create this security group  
  key_name         = module.ec2_key_pair.key_name  # Replace with your key pair name
  associate_public_ip_address = false
  root_volume_size = 20

  tags = {
    Environment = "dev"
    Project     = "nsfwctl"
  }
}

module "bastion_host" {
  source = "./modules/ec2"

  instance_name = "bastion"
  instance_type = "t2.micro"
  subnet_id = module.vpc.public_subnet_ids[1]
  vpc_security_group_ids = [module.sg.security_group_id]
  key_name = module.ec2_key_pair.key_name
  associate_public_ip_address = true
  root_volume_size = 20

    tags = {
    Environment = "dev"
    Project     = "nsfwctl"
  }
}