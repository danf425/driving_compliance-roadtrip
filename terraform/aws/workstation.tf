resource "aws_security_group" "workstation" {
  name = format(
    "${var.tag_project}-security-group-${random_id.instance_id.hex}",
  )
  description = format("Security group for ${var.tag_project}")

  // SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9631
    to_port     = 9631
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9632
    to_port     = 9632
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9638
    to_port     = 9638
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9638
    to_port     = 9638
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = format("workstation_security-group_${random_id.instance_id.hex}")
    X-Customer = var.tag_customer
    X-Project  = var.tag_project
  }
}

// Render template file for code-server.service with code_server_password variable

data "template_file" "code-server_service_config" {
  template = file("${path.module}/files/code-server.service.tpl")

  vars = {
    code_server_password = var.code_server_password
  }
}

// Provision Workstations

resource "aws_instance" "workstation" {
  count                  = var.workstation_count
  ami                    = data.aws_ami.centos7.id
  key_name               = var.aws_key_pair_name
  instance_type          = var.workstation_type
  ebs_optimized          = false
  vpc_security_group_ids = [aws_security_group.workstation.id]

  root_block_device {
    delete_on_termination = true
    volume_size           = var.workstation_volume_size
    volume_type           = "gp2"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = var.workstation_user
    private_key = file(var.aws_key_pair_file)
  }

  provisioner "file" {
    # source      = "${format("${path.module}/files/code-server.service")}"
    content     = data.template_file.code-server_service_config.rendered
    destination = "/tmp/code-server.service"
  }

  provisioner "file" {
    source      = format("${path.module}/files/code-server-settings.json")
    destination = "/tmp/code-server-settings.json"
  }

  provisioner "file" {
    source      = format("${path.module}/files/code-server-light-theme-settings.json")
    destination = "/tmp/code-server-light-theme-settings.json"
  }

  provisioner "file" {
    source = format("${path.module}/data-sources/provision-workstation.sh")

    # content     = "${data.template_file.provision-workstation.rendered}"
    destination = "/tmp/provision-workstation.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-workstation.sh",
      "/tmp/provision-workstation.sh ${var.workstation_user_password}",
    ]
    # script = "${format("${path.module}/data-sources/provision-workstation.sh")}"
  }

  provisioner "remote-exec" {
    script = format("${path.module}/data-sources/setup-code-server.sh")
  }

  tags = {
    Name       = format("${var.tag_project}_workstation_${count.index + 1}")
    X-Customer = var.tag_customer
    X-Project  = var.tag_project
  }
}

