#!/bin/bash
set -eu -o pipefail

export a2_token

a2_token="$(cat $HOME/automate-credentials.toml | sed -n -e 's/^api-token = //p' | tr -d '"')"

jq -n --arg a2_token "$a2_token" '{"a2_token":$a2_token}'
