resource "aws_iam_role" "tf-node-role" {
    name = "tf_node_iam_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid    = ""
            Principal = {
            Service = "ec2.amazonaws.com"
            }
        },
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "tf-node-policy-AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.tf-node-role.name
}

resource "aws_iam_role_policy_attachment" "tf-node-policy-AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.tf-node-role.name
}

resource "aws_iam_role_policy_attachment" "tf-node-policy-AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.tf-node-role.name
}


resource "aws_eks_node_group" "tf-node-grp" {
    cluster_name = aws_eks_cluster.tf-eks-cluster.name
    node_group_name = var.cluster-node-name
    node_role_arn = aws_iam_role.tf-node-role.arn
    subnet_ids = aws_subnet.tf-eks-subnets[*].id
    instance_types = ["t2.micro"]
    disk_size = 10

    scaling_config {
      desired_size = 3
      max_size = 5
      min_size = 1
    }

    depends_on = [
      aws_iam_role_policy_attachment.tf-node-policy-AmazonEC2ContainerRegistryReadOnly,
      aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
      aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy
    ]
  
}