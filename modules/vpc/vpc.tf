#VPC COMPONENTS

resource "aws_vpc" "terraform6_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "terraform6_vpc"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.terraform6_vpc.id
  cidr_block        = var.public_subnet1_cidr
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.terraform6_vpc.id
  cidr_block        = var.public_subnet2_cidr
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.terraform6_vpc.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.terraform6_vpc.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform6_vpc.id

}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.terraform6_vpc.id
  depends_on = [aws_internet_gateway.igw]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table" "private_rt-1" {
  vpc_id = aws_vpc.terraform6_vpc.id
  depends_on = [aws_nat_gateway.natgw]

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
    }
}

resource "aws_route_table" "private_rt-2" {
  vpc_id = aws_vpc.terraform6_vpc.id
  depends_on = [aws_nat_gateway.natgw2]

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw2.id
    }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "rtb" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "rtc" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt-1.id
}

resource "aws_route_table_association" "rtd" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rt-2.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  subnet_id     = aws_subnet.public_subnet1.id
  allocation_id = aws_eip.nat_eip.id
}

resource "aws_eip" "nat_eip2" {
  domain = "vpc"
}
resource "aws_nat_gateway" "natgw2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.public_subnet2.id
}
