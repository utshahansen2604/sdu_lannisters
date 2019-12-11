provider "aws" {
  //version = ">= 2.28.1"
  region = "ap-south-1"
  profile= "ShellPowerUser"
}

terraform {
  required_version = ">= 0.12.0"
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

variable "vpc_id" {
  default = "vpc-2e0c0d46"
}

data "aws_subnet_ids" "subnet_id" {
  
  vpc_id = "${var.vpc_id}"

}

# data "aws_subnet_ids" "default_subnets"
# {
#   vpc_id= "${aws_default_vpc.default_vpc.id}"
# }

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.10"
}


# locals {
#   cluster_name = "test-eks-${random_string.suffix.result}"
# }

# resource "random_string" "suffix" {
#   length  = 8
#   special = false
# }

resource "aws_security_group" "lan-worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
  tags = {
    Name= "Lan-Worker-SG"
  }
}

# resource "aws_security_group" "lan-worker_group_mgmt_two" {
#   name_prefix = "worker_group_mgmt_two"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "192.168.0.0/16",
#     ]
#   }
# }

resource "aws_security_group" "lan-all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "2.6.0"

#   name                 = "lan-vpc-test"
#   cidr                 = "10.0.0.0/16"
#   azs                  = data.aws_availability_zones.available.names
#   private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
#   enable_nat_gateway   = true
#   single_nat_gateway   = true
#   enable_dns_hostnames = true

#   tags = {
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#     Name = "Lan-Test-VPC"
#   }

#   public_subnet_tags = {
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#     "kubernetes.io/role/elb"                      = "1"
#   }

#   private_subnet_tags = {
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#     "kubernetes.io/role/internal-elb"             = "1"
#   }
# }

data "aws_availability_zones" "available" {
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "Lan-EKS-Test"
  subnets      = ["subnet-8d614fe5","subnet-a11a86ed","subnet-c49a3cbf"]
  kubeconfig_aws_authenticator_env_variables = {
             AWS_PROFILE = "ShellPowerUser"
  }
  #role_arn = aws_iam_role.lan-eks-role-test.arn

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
    Name="Lan-EKS-Test"
  }

  vpc_id = var.vpc_id

  worker_groups = [
    {
      name                          = "lan-worker-group-1"
      instance_type                 = "t3.medium"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.lan-worker_group_mgmt_one.id]
    },
    # {
    #   name                          = "lan-worker-group-2"
    #   instance_type                 = "t2.micro"
    #   additional_userdata           = "echo foo bar"
    #   additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
    #   asg_desired_capacity          = 1
    # },
  ]

  //worker_additional_security_group_ids = [aws_security_group.lan-all_worker_mgmt.id]
  map_roles                            = var.map_roles
  # map_users                            = var.map_users
  # map_accounts                         = var.map_accounts
}

resource "aws_iam_role" "lan-eks-role-test"{
  name = "lan-eks-role-test"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "lan-eks-test-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.lan-eks-role-test.name
}

resource "aws_iam_role_policy_attachment" "lan-eks-test-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.lan-eks-role-test.name
}