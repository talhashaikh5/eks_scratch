variable "cluster-name" {
    default = "tf-eks-cluster"
    type = string
    description = "Name of the EKS Cluster" 
}

variable "cluster-node-name" {
    default = "tf-eks-node"
    type = string
    description = "Name of the EKS Cluster Node Name" 
}


variable "kubernetes-version" {
    default = "1.21"
    type = string
    description = "Kubernetes Version" 
}

data "aws_availability_zones" "available" {

}