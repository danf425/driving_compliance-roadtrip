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

// Automate Variables
variable "automate_hostname" {
  description = "Hostname of the a2 server. Will also be used for DNS entry into zone specified below."
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
  description = "automate_private_key is the SSL private key that will be used to congfigure HTTPS for A2"
}

variable "automate_custom_ssl_cert_chain" {
  default="Paste certificate chain here"
  description = "automate_cert_chain is the SSL certificate chain that will be used to congfigure HTTPS for A2"
}

// Habitat Settings
#
# variable "origin" {
#   default = ""
# }


# ////////////////////////////////
# // Chef Automate
#
# variable "channel" {
#   default="current"
#   description = "channel is the habitat channel which will be used for installing A2"
# }
#
# variable "automate_hostname" {
#   description = "automate_hostname is the hostname which will be given to your A2 instance"
# }
#
# variable "automate_license" {
#   default = "Contact Chef Sales at sales@chef.io to request a license."
#   description = "automate_license is the license key for your A2 installation"
# }
#
# variable "automate_alb_acm_matcher" {
#   default = "*.chef-demo.com"
#   description = "Matcher to look up the ACM cert for the ALB (when using chef_automate_alb.tf"
# }
#
# variable "automate_alb_r53_matcher" {
#   default = "chef-demo.com."
#   description = "Matcher to find the r53 zone"
# }
#
# variable "automate_custom_ssl" {
#   default = "false"
#   description = "Enable to configure automate with the below certificate"
# }
#
# variable "automate_custom_ssl_private_key" {
#   default="Paste private key here"
#   description = "automate_private_key is the SSL private key that will be used to congfigure HTTPS for A2"
# }
#
# variable "automate_custom_ssl_cert_chain" {
#   default="Paste certificate chain here"
#   description = "automate_cert_chain is the SSL certificate chain that will be used to congfigure HTTPS for A2"
# }
#
# variable "automate_server_instance_type" {
#   default = "m4.xlarge"
#   description = "automate_server_instance_type is the AWS instance type to be used for A2"
# }
#
# /////////////////////////////////
# // Concourse CI Variables
#
# variable "concourse_db_node_size" {
#   default = "t2.medium"
#   description = "concourse_db_node_size is the AWS instance type to be used for Concourse's dabatase server"
#
# }
# variable "concourse_web_node_size" {
#   default = "t2.medium"
#   description = "concourse_web_node_size is the AWS instance type to be used for Concourse's web server"
# }
# variable "concourse_worker_node_size" {
#   default = "t2.medium"
#   description = "concourse_worker_node_size is the AWS instance type to be used for Concourse's worker server(s)"
# }
#
# variable "concourse_worker_count" {
#   default = "3"
#   description = "concourse_worker_count is the number of concourse worker servers to build. We recommend at least 2."
# }
#
# variable "concourse_user_name" {
#   default = "admin"
#   description = "concourse_user_name is the username which will be used to log in to the concourse web UI"
# }
# variable "concourse_user_password" {
#   default = "O3OKE47ZhPeYUad9kXcRgD!v"
#   description = "concourse_password is the password which will be used to log in to the concourse web UI"
# }
#