#!/bin/bash
set -eu -o pipefail

export ssh_user
export ssh_key
export a2_ip
export out_path
export origin

eval "$(jq -r '@sh "export ssh_user=\(.ssh_user) ssh_key=\(.ssh_key) a2_ip=\(.a2_ip) out_path=\(.out_path) origin=\(.origin)"')"

scp -i ${ssh_key} ${ssh_user}@${a2_ip}:/home/${ssh_user}/automate-credentials.toml $out_path/automate-credentials-${a2_ip}.toml

a2_admin="$(cat $out_path/automate-credentials-${a2_ip}.toml | sed -n -e 's/^username = //p' | tr -d '"')"
a2_password="$(cat $out_path/automate-credentials-${a2_ip}.toml | sed -n -e 's/^password = //p' | tr -d '"')"
a2_token="$(cat $out_path/automate-credentials-${a2_ip}.toml | sed -n -e 's/^api-token = //p' | tr -d '"')"
a2_url="$(cat $out_path/automate-credentials-${a2_ip}.toml | sed -n -e 's/^url = //p' | tr -d '"')"

if [ -f $out_path/attributes.env ] ; then
  rm $out_path/attributes.env
fi

echo -e export HAB_ORIGIN=$origin >> $out_path/attributes.env
echo -e export SERVER_URL=$a2_url/data-collector/v0 >> $out_path/attributes.env
echo -e export TOKEN=$a2_token >> $out_path/attributes.env

jq -n --arg a2_admin "$a2_admin" \
      --arg a2_password "$a2_password" \
      --arg a2_token "$a2_token" \
      --arg a2_url "$a2_url" \
      '{"a2_admin":$a2_admin,"a2_password":$a2_password,"a2_token":$a2_token,"a2_url":$a2_url}'
