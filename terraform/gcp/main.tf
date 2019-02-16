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
  fqdn = "${var.automate_hostname}.${substr(data.google_dns_managed_zone.chef-demo.dns_name, 0, length(data.google_dns_managed_zone.chef-demo.dns_name) - 1)}"
}
