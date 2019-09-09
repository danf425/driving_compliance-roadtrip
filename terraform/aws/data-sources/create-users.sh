#!/bin/bash
set -eu -o pipefail

export ssh_user
export ssh_key
export a2_ip
export out_path
export origin
export a2_url
export count

eval "$(jq -r '@sh "export count=\(.count) a2_url=\(.a2_url) ssh_user=\(.ssh_user) ssh_key=\(.ssh_key) a2_ip=\(.a2_ip) out_path=\(.out_path) origin=\(.origin)"')"

scp -i ${ssh_key} ${ssh_user}@${a2_ip}:/home/${ssh_user}/automate-credentials.toml $out_path/automate-credentials-${a2_ip}.toml

a2_token="$(cat $out_path/automate-credentials-${a2_ip}.toml | sed -n -e 's/^api-token = //p' | tr -d '"')"
# echo -e export TOK=$a2_token 

curl -H "api-token: $a2_token" -H "Content-Type: application/json" -d '{"name":"Student Six", "username":"user006", "password":"LCRr0@dtr1p"}' https://jwolf-a2.workshops.learn.chef.io/api/v0/auth/users?pretty