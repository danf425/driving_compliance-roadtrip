output "chef_automate_public_ip" {
  value = "${aws_instance.chef_automate.public_ip}"
}

output "chef_automate_server_public_r53_dns" {
  value = "${var.automate_hostname}"
}

output "a2_admin_username" {
  value = "${data.external.a2_account.result["a2_admin"]}"
}

output "a2_admin_password" {
  value = "${data.external.a2_password.result["a2_password"]}"
}

output "a2_token" {
  value = "${data.external.a2_token.result["a2_token"]}"
}
