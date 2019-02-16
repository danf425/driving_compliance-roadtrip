output "automate_lb_url" {
  value = "https://${azurerm_dns_a_record.automate_lb_dns.name}.${var.automate_app_gateway_dns_zone}"
}

output "automate_lb_ip" {
  value = "${azurerm_public_ip.automate_lb_pip.ip_address}"
}

output "automate_ip" {
  value = "${azurerm_public_ip.automate_pip.ip_address}"
}
output "a2_admin_username" {
  value = "${data.external.a2_account.result["a2_admin"]}"
}

output "a2_admin_password" {
  value = "${data.external.a2_password.result["a2_password"]}"
}

output "a2_token" {
  value = "${data.external.a2_token.result["a2_token"]}"
}