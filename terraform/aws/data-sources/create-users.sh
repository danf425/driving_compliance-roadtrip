#!/bin/bash
set -eu -o pipefail

for ((i=1; i<=$USER_COUNT; i++))
do
  curl -k -H "api-token: $(sudo chef-automate iam token create admin1 --admin)" -H "Content-Type: application/json" -d "{\"name\":\"student ${i}\", \"username\":\"user${i}\", \"password\":\"${USER_PASSWORD}\"}" https://$A2_HOSTNAME/api/v0/auth/users?pretty
done