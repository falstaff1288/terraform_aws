provider "aws" {
  region = "ca-central-1"
}

locals {
  cluster_name = "test-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
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

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

}

# Setup security-group
module "linux_web_server_sg" { 
  source 		= "terraform-aws-modules/security-group/aws"

  name			= "linux_web_server"
  description		= "Linux web server security group"
  vpc_id		= module.vpc.vpc_id
  ingress_cidr_blocks	= ["0.0.0.0/0"]
  ingress_rules		= ["https-443-tcp", "ssh-tcp"]
  
}

# Setup key pair
resource "aws_key_pair" "denis_g7" {
  key_name   = var.ssh_keypair.key_name
  public_key = var.ssh_keypair.public_key
}

data "aws_eks_cluster" "cluster" {
  name = module.my-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.my-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "my-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.17"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type = "t3.medium"
      asg_max_size  = 3
    }
  ]
  
  # Need to be defined as the deployment fails with a gp3 volume type
  # See: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1205
  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_additional_security_group_ids = [module.linux_web_server_sg.this_security_group_id]
}
