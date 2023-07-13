output "nomad_servers_public_ips" {
  value = module.nomad_public[*].public_ip
}
