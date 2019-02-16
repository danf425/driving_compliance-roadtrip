#!/bin/bash
set -eu -o pipefail

export a2_admin

a2_admin="$(cat $HOME/automate-credentials.toml | sed -n -e 's/^username = //p' | tr -d '"')"

jq -n --arg a2_admin "$a2_admin" '{"a2_admin":$a2_admin}'
