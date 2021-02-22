provider "aws" {
  region = "ca-central-1"
}

# Setup network
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "terraform-vpc"
  cidr = "10.0.0.0/16"

  # Single NAT Gateway
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames = true

  azs			= ["ca-central-1a", "ca-central-1b", "ca-central-1d"]
  private_subnets 	= ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets	= ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

}

# Setup security-group
module "linux_web_server_sg" { 
  source 		= "terraform-aws-modules/security-group/aws"

  name			= "linux_web_server"
  description		= "Linux web server security group"
  vpc_id		= module.vpc.vpc_id
  ingress_cidr_blocks	= ["0.0.0.0/0"]
  ingress_rules		= ["https-443-tcp", "ssh-tcp"]
  #ingress_with_cidr_blocks = [
  #  {
  #    from_port   = 9090
  #    to_port     = 9090
  #    protocol    = "tcp"
  #    description = "Prometheus"
  #    cidr_blocks = "0.0.0.0/0"
  #  },
  #]
  
}

# Setup key pair
resource "aws_key_pair" "denis_g7" {
  key_name   = var.ssh_keypair.key_name
  public_key = var.ssh_keypair.public_key
}

# Setup autoscaling-group

module "auto-scaling-group" {
  source 		= "terraform-aws-modules/autoscaling/aws"
  version 		= "~> 3.0"

  # Launch configuration
  name = "terraform-asg"
  
  lc_name 		= "terraform-asg"
  
  image_id 		= "ami-075cfad2d9805c5f2"
  instance_type 	= "t3a.nano"
  key_name		= "denis@g7" 
  security_groups 	= [module.linux_web_server_sg.this_security_group_id]
  associate_public_ip_address = true
  iam_instance_profile	= "AmazonSSMManagedInstanceCore"
  
  root_block_device = [
    {
      volume_size = "20"
      volume_type = "gp2"
    },
  ]


  # Auto scaling group
  asg_name		= "terraform-asg"
  vpc_zone_identifier	= module.vpc.public_subnets
  health_check_type     = "EC2"
  min_size		= 0
  max_size		= 2
  desired_capacity	= 1
  wait_for_capacity_timeout = 0
  
  tags = [
    {
      key		= "Environnement"
      value		= "dev"
      propagate_at_launch = true
    },
    {
      key		= "Project"
      value		= "terraform-test"
      propagate_at_launch = true
    },
  ]
}
