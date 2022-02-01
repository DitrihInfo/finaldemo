output "vpc_id" {
  value = aws_vpc.newvpc.id
}

output "privsubnets_ids" {
  value = aws_subnet.privsubnets[*].id
}
output "pubsubnets_ids" {
  value = aws_subnet.pubsubnets[*].id
}

output "load_balancer_link" {
  value = aws_alb.mylb.dns_name
}