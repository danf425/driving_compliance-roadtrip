provider "google" {
 credentials = "${file("${var.gcp_credentials_file}")}"
 project = "${var.gcp_project}"
 region = "${var.gcp_region}"
}

resource "random_id" "instance_id" {
  byte_length = 4
}

data "google_compute_zones" "available" {
}

resource "google_compute_instance" "a2" {
  name         = "${var.automate_hostname}-${random_id.instance_id.hex}"
  hostname     = "${var.automate_hostname}.${var.automate_dns_zone}"
  machine_type = "${var.automate_machine_type}"
  zone         = "${data.google_compute_zones.available.names[0]}" // Default to first available zone
  allow_stopping_for_update = true // Let Terraform resize on the fly if needed

  labels {
    x-contact     = "${var.label_contact}"
    x-customer    = "${var.label_customer}"
    x-project     = "${var.label_project}"
    x-dept        = "${var.label_dept}"
    x-application = "${var.label_application}"
    x-ttl         = "${var.label_ttl}"
  }

  metadata {
    sshKeys = "${var.label_contact}:${file("${var.gcp_ssh_public_key}")}"
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
    network = "default"
    access_config {
    }
  }
}
