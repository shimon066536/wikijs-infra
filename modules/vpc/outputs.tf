output "public_subnet_ids" {
  value = local.public_subnet_ids
}

output "private_subnet_ids" {
  value      = local.private_subnet_ids
  depends_on = [aws_route_table_association.private_a, aws_route_table_association.private_b]
}

output "vpc_id" {
  value = local.vpc_id
}

output "private_subnet_cidrs" {
  value = [
    aws_subnet.private_a.cidr_block,
    aws_subnet.private_b.cidr_block
  ]
}