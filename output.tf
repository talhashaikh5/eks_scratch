locals {
  config_map_aws_auth = <<CONGIGMAPAWSAUTH

apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace:kube-system
data:
  mapRoles:
    - rolearm: ${aws_iam_role.tf-node-role.arn}
      username: system:node:{{EC2@PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system: nodes
  CONGIGMAPAWSAUTH


    kubeconfig = <<KUBECONFIG

apiVesion: v1
clusters:
- clusterL
    server: ${aws_eks_cluster.tf-eks-cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.tf-eks-cluster.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
  cluster: kubernetes
  user: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster-name}
KUBECONFIG
}

output "config_map_aws_auth" {
    value = local.config_map_aws_auth
}

output "kubeconfig" {
    value = local.kubeconfig
}


resource "null_resource" "update" {
    depends_on = [
      aws_eks_cluster.tf-eks-cluster
    ]
    provisioner "local-exec" {
        command = "aws eks update-kubeconfig --name ${var.cluster-name}"
        # interpreter = [
        #   "/bin/zsh"
        # ]
    }

}
