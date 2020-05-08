locals {
  full_cert_chain = "${acme_certificate.a2_cert.certificate_pem}${acme_certificate.a2_cert.issuer_pem}"
}

resource "google_compute_address" "a2_ext_ip" {
  name = "a2-ext-ip-${random_id.instance_id.hex}"
  address_type = "EXTERNAL"
}

resource "google_dns_record_set" "a2_dns" {
  project = "${data.google_dns_managed_zone.chef-demo.project}"
  name = "${var.automate_hostname}.${data.google_dns_managed_zone.chef-demo.dns_name}"
  managed_zone = "${data.google_dns_managed_zone.chef-demo.name}"
  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_address.a2_ext_ip.address}"]
}

resource "google_compute_instance" "a2" {
  name         = "${var.automate_hostname}-${random_id.instance_id.hex}"
  hostname     = "${local.fqdn}"
  machine_type = "${var.automate_machine_type}"
  zone         = "${data.google_compute_zones.available.names[0]}" // Default to first available zone
  allow_stopping_for_update = true // Let Terraform resize on the fly if needed

  labels {
    x-contact     = "${var.label_contact}"
    x-customer    = "${var.label_customer}"
    x-project     = "${var.label_project}"
    x-dept        = "${var.label_dept}"
    x-application = "${var.label_application}"
    X-TTL         = "${var.label_ttl}"
  }

  metadata {
    sshKeys = "${var.automate_ssh_username}:${file("${var.gcp_ssh_public_key}")}"
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      type = "pd-ssd"
      size = 100
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    network = "${google_compute_network.a2_network.name}"
    access_config {
      nat_ip = "${google_compute_address.a2_ext_ip.address}"
    }
  }

  provisioner "file" {
    destination = "/tmp/ssl_cert"
    content = "${var.automate_custom_ssl ? var.automate_custom_ssl_cert_chain : local.full_cert_chain}"

    connection {
      user     = "${var.automate_ssh_username}"
      private_key = "${file("${var.gcp_ssh_private_key}")}"
    }
  }

  provisioner "file" {
    destination = "/tmp/ssl_key"
    content = "${var.automate_custom_ssl ? var.automate_custom_ssl_private_key : acme_certificate.a2_cert.private_key_pem}"

    connection {
      user     = "${var.automate_ssh_username}"
      private_key = "${file("${var.gcp_ssh_private_key}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sysctl -w vm.max_map_count=262144",
      "sudo sysctl -w vm.dirty_expire_centisecs=20000",
      "sudo curl https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip |gunzip - > chef-automate && chmod +x chef-automate",
      "sudo mv chef-automate /usr/sbin/chef-automate",
      "sudo mkdir -p /etc/chef-automate",
      "sudo chef-automate init-config --file /tmp/config.toml --certificate /tmp/ssl_cert --private-key /tmp/ssl_key",
      "sudo sed -i 's/fqdn = \".*\"/fqdn = \"${local.fqdn}\"/g' /tmp/config.toml",
      "sudo sed -i 's/channel = \".*\"/channel = \"${var.automate_channel}\"/g' /tmp/config.toml",
      "sudo sed -i 's/license = \".*\"/license = \"${var.automate_license}\"/g' /tmp/config.toml",
      "sudo rm -f /tmp/ssl_cert /tmp/ssl_key",
      "sudo mv /tmp/config.toml /etc/chef-automate/config.toml",
      "sudo chef-automate deploy /etc/chef-automate/config.toml --accept-terms-and-mlsa",
      "sudo chown ${var.automate_ssh_username}:${var.automate_ssh_username} $HOME/automate-credentials.toml",
      "sudo echo -e api-token = \"$(sudo chef-automate admin-token)\" >> $HOME/automate-credentials.toml",
      "sudo cat $HOME/automate-credentials.toml",
    ]

    connection {
      user     = "${var.automate_ssh_username}"
      private_key = "${file("${var.gcp_ssh_private_key}")}"
    }
  }
  provisioner "local-exec" {
    // Clean up local known_hosts in case we get a re-used public IP
    command = "ssh-keygen -R ${google_compute_address.a2_ext_ip.address}"
  }

  provisioner "local-exec" {
    // Write ssh key for Automate server to local known_hosts so we can scp automate-credentials.toml in data.external.a2_secrets
    command = "ssh-keyscan -t ecdsa ${google_compute_address.a2_ext_ip.address} >> ~/.ssh/known_hosts"
  }
}

data "external" "a2_secrets" {
  program = ["bash", "${path.module}/data-sources/get-automate-secrets.sh"]
  depends_on = ["google_compute_instance.a2"]

  query = {
    ssh_user = "${var.automate_ssh_username}"
    ssh_key  = "${var.gcp_ssh_private_key}"
    a2_ip    = "${google_compute_address.a2_ext_ip.address}"
    out_path = "${path.root}"
    origin   = "${var.origin}"
  }
}
