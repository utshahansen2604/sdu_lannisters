provider "aws" {
  region  = "ap-south-1"
  profile = "ShellPowerUser"
}

data "aws_availability_zones" "available" {
}

resource "aws_vpc" "lannister_eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name"                                      = "lannister-eks-vpc"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_subnet" "lannister_eks_subnet" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.lannister_eks_vpc.id}"

  tags = {
    "Name"                                      = "lannister-eks-subnet"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_internet_gateway" "lannister_ig" {
  vpc_id = "${aws_vpc.lannister_eks_vpc.id}"

  tags = {
    Name = "lannister-eks-ig"
  }
}

resource "aws_route_table" "lannister_routetable" {
  vpc_id = "${aws_vpc.lannister_eks_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.lannister_ig.id}"
  }
}

resource "aws_route_table_association" "lannister_routetable_assoc" {
  count          = 2
  subnet_id      = "${aws_subnet.lannister_eks_subnet[count.index].id}"
  route_table_id = "${aws_route_table.lannister_routetable.id}"
}


resource "aws_iam_role" "lannister-eks-role" {
  name = "lannister-eks-role"

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

resource "aws_iam_role_policy_attachment" "lannister-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.lannister-eks-role.name}"
}

resource "aws_iam_role_policy_attachment" "lannister-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.lannister-eks-role.name}"
}


resource "aws_security_group" "lannister-eks-sg" {
  name        = "lannister-eks-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.lannister_eks_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lannister-eks-sg"
  }
}

# resource "aws_eks_cluster" "lannister_cluster" {
#   name     = "lannister_cluster"
#   role_arn        = "${aws_iam_role.lannister-eks-role.arn}"

#   vpc_config {
#     subnet_ids = ["${aws_default_subnet.lannister_cluster_subnet_1a.id}","${aws_default_subnet.lannister_cluster_subnet_1b.id}"]
#   }
# }

variable "cluster-name" {
  default = "lannister_cluster"
  type    = string
}

resource "aws_eks_cluster" "lannister_cluster" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.lannister-eks-role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.lannister-eks-sg.id}"]
    subnet_ids         = aws_subnet.lannister_eks_subnet.*.id
  }

  depends_on = [
    "aws_iam_role_policy_attachment.lannister-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.lannister-cluster-AmazonEKSServicePolicy",
  ]
}

output "endpoint" {
  value = "${aws_eks_cluster.lannister_cluster.endpoint}"
}

output "kubeconfig-certificate-authority-data" {
  value = "${aws_eks_cluster.lannister_cluster.certificate_authority.0.data}"
}
