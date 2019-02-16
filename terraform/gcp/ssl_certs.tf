provider "acme" {
  server_url = "${var.acme_provider_url}"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "${var.label_contact}@chef.io"
}

resource "acme_certificate" "a2_fe_cert" {
  account_key_pem = "${acme_registration.reg.account_key_pem}"
  common_name     = "${var.automate_hostname}-fe.${local.domain}"
  #subject_alternative_names = ["${google_dns_record_set.a2_dns.name}-fe.${azurerm_dns_a_record.automate_lb_dns.zone_name}"]

  dns_challenge {
    provider = "gcloud"

    config {
      GCE_PROJECT = "${var.automate_dns_zone_project}"
      GCE_SERVICE_FILE = "${var.gcp_credentials_file}"
    }
  }
}