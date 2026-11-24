output "vpc_id" {
  description = "Identifiant du VPC."
  value       = aws_vpc.main.id
}

output "vm_private_ips" {
  description = "Adresses privées des machines applicatives."
  value       = [aws_instance.app.private_ip]
}
