[Unit]
Description=Code Server

[Service]
User=chef
Group=chef
Environment=PASSWORD=${code_server_password}
ExecStart=/usr/local/bin/code-server /home/chef

[Install]
WantedBy=default.target