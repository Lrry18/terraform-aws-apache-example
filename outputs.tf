
output "public_ip" {
  value = aws_instance.my_server.public_ip
}

output "private_ip" {
  value = aws_instance.my_server.private_ip
}

output "network-interface_id" {
  value = aws_instance.my_server.primary_network_interface_id
}

output "network-subnet" {
  value = aws_instance.my_server.subnet_id
}