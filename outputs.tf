output "public_lb_dns_name" {
  description = "Public LB address to connect too"
  value       = aws_lb.public.dns_name
}