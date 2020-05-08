[Unit]
Description=Code Server

[Service]
User=chef
Group=chef
Environment=PASSWORD=${code_server_password}
ExecStart=/usr/local/bin/code-server/code-server /home/chef --host 0.0.0.0

[Install]
WantedBy=default.target
