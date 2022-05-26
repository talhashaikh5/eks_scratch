resource "aws_iam_role" "tf-eks-role" {
    name = "tf-eks-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid    = ""
            Principal = {
            Service = "eks.amazonaws.com"
            }
        },
        ]
    })

    tags = {
      "Name" = "tf-eks-role"
    }


  
}

resource "aws_iam_role_policy_attachment" "tf-eks-role-AWS-EKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.tf-eks-role.name
}

resource "aws_iam_role_policy_attachment" "tf-eks-role-AWS-EKSServicePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role = aws_iam_role.tf-eks-role.name
}

resource "aws_security_group" "tf-eks-sg" {
    name = "tf-eks-sg"
    description = "Seperate SG for EKS Terraform"
    vpc_id = aws_vpc.tf-eks-vpc.id

    tags = {
      "Name" = "tf-eks-sg"
    } 
}

resource "aws_security_group_rule" "ingress-ip-local-workstation" {
    cidr_blocks = [local.workstation-external-cidr]
    description = "Access from local system"
    from_port = 443
    protocol = "tcp"
    to_port = 443
    security_group_id = aws_security_group.tf-eks-sg.id
    type = "ingress"
}

resource "aws_security_group_rule" "egress-all-ip" {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Out to all ips"
    from_port = 0
    protocol = "-1"
    to_port = 0
    security_group_id = aws_security_group.tf-eks-sg.id
    type = "egress"
}

resource "aws_eks_cluster" "tf-eks-cluster" {
    name = var.cluster-name
    version = var.kubernetes-version
    role_arn = aws_iam_role.tf-eks-role.arn

    vpc_config {
      security_group_ids = [ aws_security_group.tf-eks-sg.id ]
      subnet_ids =  aws_subnet.tf-eks-subnets[*].id 
    }

    depends_on = [
      aws_iam_role_policy_attachment.tf-eks-role-AWS-EKSClusterPolicy,
      aws_iam_role_policy_attachment.tf-eks-role-AWS-EKSServicePolicy
    ]

    tags = {
      "Name" = "tf-eks-cluster"
    }

}

resource "aws_eks_addon" "eks-addon-vpc-cni" {
  cluster_name = aws_eks_cluster.tf-eks-cluster.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "eks-addon-coredns" {
  cluster_name = aws_eks_cluster.tf-eks-cluster.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "eks-addon-kube-proxy" {
  cluster_name = aws_eks_cluster.tf-eks-cluster.name
  addon_name   = "kube-proxy"
}