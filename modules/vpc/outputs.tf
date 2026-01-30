output "vpc_id" {
   description = "The ID of the VPC"
   value       = aws_vpc.terraform6_vpc.id
}

output "public_subnet1_id" {
  description = "The IDs of the public subnet1"
  value       = aws_subnet.public_subnet1.id
}

output "public_subnet2_id" {
  description = "The IDs of the public subnet2"
  value       = aws_subnet.public_subnet2.id
}

output "private_subnet1_id" {
  description = "The IDs of the private subnet1"
  value       = aws_subnet.private_subnet1.id
}

output "private_subnet2_id" {
  description = "The IDs of the private subnet2"
  value       = aws_subnet.private_subnet2.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.natgw.id
}

output "nat_gateway2_id" {
  description = "The ID of the second NAT Gateway"
  value       = aws_nat_gateway.natgw2.id
}
