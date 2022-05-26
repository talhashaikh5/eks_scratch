resource "aws_vpc" "tf-eks-vpc" {
    cidr_block = "192.168.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    
    tags = {
        Name = "tf-eks-vpc",
        "kubernetes.io/cluster/$(var.cluster-name)" = "shared"
    }
  
}

resource "aws_subnet" "tf-eks-subnets" {
    count = length(data.aws_availability_zones.available.names)

    availability_zone = data.aws_availability_zones.available.names[count.index]
    cidr_block = "192.168.${count.index}.0/24"
    map_public_ip_on_launch = true
    vpc_id = aws_vpc.tf-eks-vpc.id

    tags = {
        Name = "tf subnet ${count.index}"
        "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    }
  
}

resource "aws_internet_gateway" "tf-eks-dnat" {
    vpc_id = aws_vpc.tf-eks-vpc.id

    tags = {
      "Name" = "tf-eks-dnat"
    }
  
}

resource "aws_route_table" "tf-eks-routetable" {
    vpc_id = aws_vpc.tf-eks-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tf-eks-dnat.id
    }
    tags = {
      "Name" = "tf-eks-routetable"
    }
  
}

resource "aws_route_table_association" "tf-eks-assoc" {
    count = length(data.aws_availability_zones.available.names)

    subnet_id = aws_subnet.tf-eks-subnets.*.id[count.index]
    route_table_id = aws_route_table.tf-eks-routetable.id
  
}