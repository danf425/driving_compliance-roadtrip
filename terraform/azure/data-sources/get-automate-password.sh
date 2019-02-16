#!/bin/bash
set -eu -o pipefail

export a2_password

a2_password="$(cat $HOME/automate-credentials.toml | sed -n -e 's/^password = //p' | tr -d '"')"

jq -n --arg a2_password "$a2_password" '{"a2_password":$a2_password}'
