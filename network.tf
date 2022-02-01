#---------------------------------------------------
# Check availability Zones
#---------------------------------------------------
data "aws_availability_zones" "available" {}

#---------------------------------------------------
# Create VPC
#---------------------------------------------------

resource "aws_vpc" "newvpc" {
    cidr_block = var.vpc_cidr
       tags = {
        Name = "${var.project}-vpc"
    }
}

#---------------------------------------------------
# Create InternetGateWay for  VPC 
#---------------------------------------------------

resource "aws_internet_gateway" "inetgtw" {
    vpc_id = aws_vpc.newvpc.id
    tags = {
        Name = "${var.project}-inetgtw"
    }
}

#---------------------------------------------------
# Create Public SubnetS :-)
#---------------------------------------------------

resource "aws_subnet" "pubsubnets" {
    count             = length(var.pubsubnet_cidr)
    vpc_id            = aws_vpc.newvpc.id
    cidr_block        = element(var.pubsubnet_cidr, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-public-${count.index + 1}"
  }
}

#---------------------------------------------------
# Create Private SubnetS :-)
#---------------------------------------------------
resource "aws_subnet" "privsubnets" {
    count             = length(var.privsubnet_cidr)
    vpc_id            = aws_vpc.newvpc.id
    cidr_block        = element(var.privsubnet_cidr, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-private-${count.index + 1}"
  }

}

#---------------------------------------------------
# Create  Elastic IP for NAT Gateways (natA ,natB)
#---------------------------------------------------

resource "aws_eip" "eip" {
  count = length(var.privsubnet_cidr)
  vpc   = true
  tags = {
    Name = "${var.project}-eip-${count.index + 1}"
  }
}

#---------------------------------------------------
# Create NAT Gateways for Elastic IP
#---------------------------------------------------

resource "aws_nat_gateway" "nat" {
  count         = length(var.privsubnet_cidr)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = element(aws_subnet.pubsubnets[*].id, count.index)
  tags = {
    Name = "${var.project}-nat-${count.index + 1}"
  }
}

#---------------------------------------------------
# Create Routing Table in Subnets through the igateway
#---------------------------------------------------

resource "aws_route_table" "routetable-pubsubnets" {
vpc_id = aws_vpc.newvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inetgtw.id
  }
  tags = {
    Name = "${var.project}-routetable-pubsubnets"
  }
}
#---------------------------------------------------
# Create Route Table Association Public Networks
#---------------------------------------------------

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.pubsubnets[*].id)
  route_table_id = aws_route_table.routetable-pubsubnets.id
  subnet_id      = element(aws_subnet.pubsubnets[*].id, count.index)
}
#---------------------------------------------------
# Create a new route table for the private subnets
#---------------------------------------------------

resource "aws_route_table" "private_subnets" {
  count        = length(var.privsubnet_cidr)
  vpc_id       = aws_vpc.newvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.project}-routetable-private-${count.index + 1}"
  }
}

#---------------------------------------------------
# Create Route Table Association Private
#---------------------------------------------------

resource "aws_route_table_association" "private_routes" {
  count          = length(aws_subnet.privsubnets[*].id)
  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id      = element(aws_subnet.privsubnets[*].id, count.index)
}

#---------------------------------------------------
# Create security_group for our vpc
#---------------------------------------------------

resource "aws_security_group" "myseqgroup" {
    name        = "demo3-sec-group"
    vpc_id = aws_vpc.newvpc.id
    description = "Security group for Demo3"    
    
   dynamic "ingress"  {
	for_each = ["22", "80",]
	content {
	        
        from_port        = ingress.value
        to_port          = ingress.value
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
      } 
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    tags = {
      Name = "-allow-22-80-ports"
    }
}
