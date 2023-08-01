output "public_ips" {
  value = module.vault_server[*].public_ip
}

output "instance_ids" {
  value = module.vault_server[*].id
}
