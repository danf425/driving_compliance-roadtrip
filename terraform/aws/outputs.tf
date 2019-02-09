output "chef_automate_public_ip" {
  value = "${aws_instance.chef_automate.public_ip}"
}

output "chef_automate_server_public_r53_dns" {
  value = "${var.automate_hostname}"
}