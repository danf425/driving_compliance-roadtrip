resource "azurerm_public_ip" "app_gateway_pip" {
  name                = "${var.tag_contact}-${var.tag_application}-pip"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  sku                 = "Standard"
  allocation_method   = "Static"
  # app_gateway cannot use dynamic public ips
}

resource "azurerm_dns_a_record" "app_gateway_dns" {
  name                = "${var.tag_contact}-automate-${random_id.randomId.hex}"
  zone_name           = "${var.automate_app_gateway_dns_zone}"
  resource_group_name = "azure-dns-rg"
  ttl                 = 300
  records             = ["${azurerm_public_ip.app_gateway_pip.ip_address}"]
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet.name}-rqrt"
}

# Azure Application Gateways require a *.pfx formatted SSL Certificate. This
# little snppet creates the *.pfx cert from the ACME PEM files.
data "external" "ag-pfx" {
  program = ["bash", "${path.module}/data-sources/generate-pfx.sh"]

  query = {
    certificate_pem = "${acme_certificate.app_gateway_cert.certificate_pem}"
    private_key_pem = "${acme_certificate.app_gateway_cert.private_key_pem}"
  }
}

#data "external" "automate-pfx" {
#  program = ["bash", "${path.module}/data-sources/generate-pfx.sh"]
#
#  query = {
#    certificate_pem = "${acme_certificate.app_gateway_cert.certificate_pem}"
#    private_key_pem = "${acme_certificate.app_gateway_cert.private_key_pem}"
#  }
#}

resource "azurerm_application_gateway" "network" {
  name                = "${var.tag_contact}-${var.tag_application}-appgateway"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.tag_contact}-${var.tag_application}-gw-ip-conf"
    subnet_id = "${azurerm_subnet.frontend.id}"
  }

  frontend_port {
    name = "${local.frontend_port_name}"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "${local.frontend_ip_configuration_name}"
    public_ip_address_id = "${azurerm_public_ip.app_gateway_pip.id}"
  }

  backend_address_pool {
    name = "${local.backend_address_pool_name}"
    fqdn_list = ["${azurerm_network_interface.automate_nic.private_ip_address}"]
  }

  backend_http_settings {
    name                  = "${local.http_setting_name}"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 1

#    authentication_certificate {
#      name = "automate-ssl-cert"
#    }
  }

#  authentication_certificate {
#    name     = "automate-ssl-cert"
#    data     = "${data.external.automate-pfx.result["pfx"]}"
#  }

  http_listener {
    name                           = "${local.listener_name}"
    frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}"
    frontend_port_name             = "${local.frontend_port_name}"
    protocol                       = "Https"
    ssl_certificate_name = "ag-ssl-cert"
  }

  ssl_certificate {
    name     = "ag-ssl-cert"
    data     = "${data.external.ag-pfx.result["pfx"]}"
    password = ""
  }

  request_routing_rule {
    name                       = "${local.request_routing_rule_name}"
    rule_type                  = "Basic"
    http_listener_name         = "${local.listener_name}"
    backend_address_pool_name  = "${local.backend_address_pool_name}"
    backend_http_settings_name = "${local.http_setting_name}"
  }
}
