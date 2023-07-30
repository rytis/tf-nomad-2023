output "public_ips" {
  value = module.nomad_worker[*].public_ip
}

output "instance_ids" {
  value = module.nomad_worker[*].id
}
