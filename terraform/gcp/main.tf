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

data "google_dns_managed_zone" "chef-demo" {
  project = "${var.automate_dns_zone_project}"
  name = "${var.automate_dns_zone_name}"
}

resource "google_compute_instance" "a2" {
  name         = "${var.automate_hostname}-${random_id.instance_id.hex}"
  // hostname is FQDN, but GCP returns a trailing '.' from the managed zone data that needs to be stripped
  hostname     = "${var.automate_hostname}.${substr(data.google_dns_managed_zone.chef-demo.dns_name, 0, length(data.google_dns_managed_zone.chef-demo.dns_name) - 1)}"
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

resource "google_dns_record_set" "a2_dns" {
  project = "${data.google_dns_managed_zone.chef-demo.project}"
  name = "${var.automate_hostname}.${data.google_dns_managed_zone.chef-demo.dns_name}"
  managed_zone = "${data.google_dns_managed_zone.chef-demo.name}"
  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_instance.a2.network_interface.0.access_config.0.nat_ip}"]
}
