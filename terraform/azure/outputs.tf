output "app_gateway_url" {
  value = "https://${azurerm_dns_a_record.app_gateway_dns.name}.${var.automate_app_gateway_dns_zone}"
}

output "app_gateway_ip" {
  value = "${azurerm_public_ip.app_gateway_pip.ip_address}"
}

output "automate_url" {
  value = "https://${azurerm_dns_a_record.automate_dns.name}.${var.automate_app_gateway_dns_zone}"
}

output "automate_ip" {
  value = "${azurerm_public_ip.automate_pip.ip_address}"
}



