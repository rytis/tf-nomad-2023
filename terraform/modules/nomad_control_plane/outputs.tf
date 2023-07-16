output "public_ips" {
  value = module.nomad_server[*].public_ip
}
