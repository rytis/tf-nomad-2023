output "nomad_servers_public_ips" {
  value = module.nomad_control_plane.public_ips
}

output "nomad_ui_dns_name" {
  value = module.nomad_ui_lb.elb_dns_name
}
