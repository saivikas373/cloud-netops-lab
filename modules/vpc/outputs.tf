output "vpc_id" {
    value = aws_vpc.this.id
}

output "public_subnet_ids" {
    value = { for name, subnet in aws_subnet.this: name => subnet.id}
}

output "private_route_table_id" {
    value = aws_route_table.private.id
}