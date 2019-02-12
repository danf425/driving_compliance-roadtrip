resource "azurerm_public_ip" "automate_pip" {
  name                = "${var.tag_contact}-automate-pip"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  sku                 = "Standard"
  allocation_method   = "Static"
  # Normally this would be dynamic, but static simplifies dynamic certs from Let's Encrypt
}

resource "azurerm_dns_a_record" "automate_dns" {
  name                = "${var.tag_contact}-automate-fe-${random_id.randomId.hex}"
  zone_name           = "${var.automate_app_gateway_dns_zone}"
  resource_group_name = "azure-dns-rg"
  ttl                 = 300
  records             = ["${azurerm_public_ip.automate_pip.ip_address}"]
}

# Create instance network interface
resource "azurerm_network_interface" "automate_nic" {
  name                      = "${var.tag_contact}-${var.tag_application}-automate-nic"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.chef_automate.id}"

  ip_configuration {
    name                          = "automate-ipconfig"
    subnet_id                     = "${azurerm_subnet.backend.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.automate_pip.id}"
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

data "template_file" "install_chef_automate_cli" {
  template = "${file("${path.module}/templates/chef_automate/install_chef_automate_cli.sh.tpl")}"
}

resource "azurerm_virtual_machine" "chef_automate" {
  name                  = "${var.tag_contact}-automate-fe-${random_id.randomId.hex}.${var.automate_app_gateway_dns_zone}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.automate_nic.id}"]
  vm_size               = "${var.automate_server_instance_type}"
  delete_os_disk_on_termination = true

  connection {
    type        = "ssh"
    user        = "${var.azure_image_user}"
    private_key = "${file("${var.azure_private_key_path}")}"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.tag_contact}-automate-fe-${random_id.randomId.hex}-osdisk"
    vhd_uri       = "${azurerm_storage_account.stor.primary_blob_endpoint}${azurerm_storage_container.storcont.name}/${var.tag_application}-chef_automate-osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = "100"
  }

  os_profile {
    computer_name  = "${var.tag_contact}-automate-fe-${random_id.randomId.hex}"
    admin_username = "${var.azure_image_user}"
    admin_password = "${var.azure_image_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_image_user}/.ssh/authorized_keys"
      key_data = "${file("${var.azure_public_key_path}")}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  provisioner "file" {
    destination = "/tmp/install_chef_automate_cli.sh"
    content     = "${data.template_file.install_chef_automate_cli.rendered}"
  }

  provisioner "file" {
    destination = "/tmp/ssl_cert"
    content = "${var.automate_custom_ssl ? var.automate_custom_ssl_cert_chain : acme_certificate.automate_cert.certificate_pem}"
  }

  provisioner "file" {
    destination = "/tmp/ssl_key"
    content = "${var.automate_custom_ssl ? var.automate_custom_ssl_private_key : acme_certificate.automate_cert.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [
      # "sudo hostnamectl set-hostname ${var.tag_contact}-automate-${random_id.randomId.hex}",
      "pwd",
      "sudo sysctl -w vm.max_map_count=262144",
      "sudo sysctl -w vm.dirty_expire_centisecs=20000",
      "curl https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip |gunzip - > chef-automate && chmod +x chef-automate",
      "sudo chmod +x /tmp/install_chef_automate_cli.sh",
      "sudo bash /tmp/install_chef_automate_cli.sh",
      "sudo ./chef-automate init-config --file /tmp/config.toml --certificate /tmp/ssl_cert --private-key /tmp/ssl_key",
      "sudo sed -i 's/fqdn = \".*\"/fqdn = \"${azurerm_virtual_machine.chef_automate.name}\"/g' /tmp/config.toml",
      "sudo sed -i 's/channel = \".*\"/channel = \"${var.channel}\"/g' /tmp/config.toml",
      "sudo sed -i 's/license = \".*\"/license = \"${var.automate_license}\"/g' /tmp/config.toml",
      "sudo rm -f /tmp/ssl_cert /tmp/ssl_key",
      "sudo mv /tmp/config.toml /etc/chef-automate/config.toml",
      "sudo ./chef-automate deploy /etc/chef-automate/config.toml --accept-terms-and-mlsa | tee",
      "sudo echo -e \"api-token =\" $(sudo chef-automate admin-token) >> $HOME/automate-credentials.toml",
      "sudo chown ${var.azure_image_user}:${var.azure_image_user} $HOME/automate-credentials.toml",
      "sudo cat $HOME/automate-credentials.toml",
    ]
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}
