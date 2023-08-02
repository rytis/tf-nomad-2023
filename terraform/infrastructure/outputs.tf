output "nomad_servers_public_ips" {
  value = module.nomad_control_plane.public_ips
}

output "vault_servers_public_ips" {
  value = module.vault_cluster.public_ips
}

output "nomad_ui_url" {
  value = "http://${module.nomad_ui_lb.elb_dns_name}/"
}

output "vault_ui_url" {
  value = "http://${module.vault_ui_lb.elb_dns_name}/"
}
