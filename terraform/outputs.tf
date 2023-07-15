output "nomad_servers_public_ips" {
  value = module.nomad_server[*].public_ip
}
