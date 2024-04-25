resource "aws_iam_role" "cluster_autoscaler" {
    name               = "clusterautoscaler"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Effect = "Allow",
            Principal = {
              Service = "ec2.amazonaws.com"
            },
            Action = "sts:AssumeRole"
          }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_at" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "ClusterAutoscalerPolicy"
  path        = "/"
  description = "Policy for EKS Cluster Autoscaler"
 
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "helm_release" "cluster_autoscaler" {
    name = "autoscaler"
    repository = "https://kubernetes.github.io/autoscaler"
    chart = "cluster-autoscaler"
    namespace = "kube-system"
    version = "9.36.0"
    
    set {
        name = "autoDiscovery.clusterName"
        value = aws_eks_cluster.ea2_eks.name
    }
    set {
        name = "awsRegion"
        value = "us-east-1"
    }
    
}