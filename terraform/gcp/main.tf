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

locals {
  // GCP returns a trailing '.' from the managed zone data that needs to be stripped
  domain = "${substr(data.google_dns_managed_zone.chef-demo.dns_name, 0, length(data.google_dns_managed_zone.chef-demo.dns_name) - 1)}"
}

resource "google_compute_network" "a2_network" {
  name = "a2-network"
}

data "google_compute_subnetwork" "a2_subnetwork" {
  name   = "${google_compute_network.a2_network.name}"
}


resource "google_compute_firewall" "a2_firewall_ingress" {
  name      = "a2-firewall-ingress"
  network   = "${google_compute_network.a2_network.name}"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "a2_firewall_egress" {
  name      = "a2-firewall-egress"
  network   = "${google_compute_network.a2_network.name}"
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

 allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "a2_firewall_internal" {
  name      = "a2-firewall-internal"
  network   = "${google_compute_network.a2_network.name}"
  direction = "INGRESS"
  source_ranges = ["${data.google_compute_subnetwork.a2_subnetwork.ip_cidr_range}"]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

 allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }
}