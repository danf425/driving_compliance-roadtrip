output "chef_automate_public_ip" {
  value = "${google_compute_instance.a2.network_interface.0.access_config.0.nat_ip}"
}
#
# output "chef_automate_server_public_r53_dns" {
#   value = "${var.automate_hostname}"
# }