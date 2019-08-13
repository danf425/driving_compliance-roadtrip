///////////////////////////////////////
// GCP Info

variable "gcp_credentials_file" {
  description = "Path to your JSON GCP credentials file on your local machine"
}

variable "gcp_project" {
  description = "Existing GCP project to use for deployment"
}

variable "gcp_region" {
  default="us-west1"
  description = <<EOF
gcp_region is the GCP region in which we will build instances

Region List: https://cloud.google.com/compute/docs/regions-zones/
EOF
}

variable "gcp_ssh_public_key" {
  description = "Path to your public SSH key file on your local machine"
}

variable "gcp_ssh_private_key" {
  description = "Path to your private SSH key file on your local machine"
}

///////////////////////////////////////
// Required Labels (aka Tags)
variable "label_customer" {
  description = "label_customer is the customer tag which will be added to AWS. lower-case, numbers, underscores, or dashes only"
}

variable "label_project" {
  description = "label_project is the project tag which will be added to AWS. lower-case, numbers, underscores, or dashes only"
}

variable "label_dept" {
  description = "label_dept is the department tag which will be added to AWS. lower-case, numbers, underscores, or dashes only"
}

variable "label_contact" {
  description = "label_contact is the contact tag which will be added to AWS. lower-case, numbers, underscores, or dashes only"
}

variable "label_application" {
  description = "label_application is the application tag which will be added to AWS. lower-case, numbers, underscores, or dashes only"
}
variable "label_ttl" {
  default = 4
}

///////////////////////////////////////
// Automate Variables

variable "automate_license" {
  default = ""
  description = "License for Automate"
}

variable "automate_hostname" {
  description = "Hostname of the automate server. Will also be used for DNS entry into zone specified below."
}

variable "automate_ssh_username" {
  description = "Username of account to create and use for SSH access along with var.gcp_ssh_private_key"
}

variable "automate_dns_zone_name" {
  description = "GCP-managed DNS zone name in which to register automate_hostname"
}

variable "automate_dns_zone_project" {
  default = "null"
  description = "Project hosting the automate_dns_zone above.  Defaults to gcp_project variable."
}

variable "automate_machine_type" {
  default = "n1-standard-4"
  description = <<EOF
GCP machine type for Automate server

Machine Types:  https://cloud.google.com/compute/docs/machine-types
EOF
}

variable "email_address" {
  description = "E-mail address used to create acme_registration for Let's Encrypt cert generation"
}

variable "acme_provider_url" {
  default = "https://acme-staging-v02.api.letsencrypt.org/directory"
  description = <<EOF
An API endpoint URL for an ACME-compliant CA.  We default to LetsEncrypt staging endpoint.
This will issue certs, but the certs will not be valid.

For valid certs from LetsEncrypt, use https://acme-v02.api.letsencrypt.org/directory
EOF
}

variable "automate_custom_ssl" {
  default = "false"
  description = "Enable to configure automate with the below certificate"
}

variable "automate_custom_ssl_private_key" {
  default="Paste private key here"
  description = "automate_private_key is the SSL private key that will be used to congfigure HTTPS for automate"
}

variable "automate_custom_ssl_cert_chain" {
  default="Paste certificate chain here"
  description = "automate_cert_chain is the SSL certificate chain that will be used to congfigure HTTPS for automate"
}

variable "automate_channel" {
  default = "current"
  description = "Release channel subscription for automate install and updates"

}

variable "origin" {
  description = "habitat  origin to use"
}
