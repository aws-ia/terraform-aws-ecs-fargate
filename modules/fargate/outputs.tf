output "Public_LB_DNS_name" {
  description = "Public LB address to connect too"
  value = aws_lb.public.dns_name
}