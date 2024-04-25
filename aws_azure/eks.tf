resource "aws_eks_cluster" "ea2_eks" {
    name = "ea2_eks"
    role_arn = aws_iam_role.eks_cluster_ea2.arn
    
    vpc_config {
    subnet_ids = [aws_subnet.ea2_psn1.id, aws_subnet.ea2_psn2.id]
    security_group_ids =[aws_security_group.open_K8SAPI_port.id]
    endpoint_private_access = true
    endpoint_public_access = true
  }
    depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
  
}

resource "aws_security_group" "open_K8SAPI_port" {
  name        = "open_K8SAPI_port"
  vpc_id      = aws_vpc.ea2_vpc.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_eg_k8s" {
  security_group_id = aws_security_group.open_K8SAPI_port.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_f_node" {
  security_group_id = aws_security_group.open_K8SAPI_port.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_cluster_ea2" {
  name               = "eks-cluster-ea2"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_ea2.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_ea2.name
}

resource "aws_iam_role" "eks_nodegroup_role" {
  name = "eks_nodegroup_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_eks_node_group" "ea2_ng" {
  cluster_name    = aws_eks_cluster.ea2_eks.name
  node_group_name = "ea2_nodegroup"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = [aws_subnet.ea2_psn1.id,aws_subnet.ea2_psn2.id] 

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_nodegroup-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_nodegroup-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_nodegroup-AmazonEC2ContainerRegistryReadOnly,
  ]
}