#!/bin/bash
set -eu -o pipefail

for ((i=1; i<=$USER_COUNT; i++))
do
  echo "Creating user${i}" ;
  curl -k -H "api-token: $API_TOKEN" -H "Content-Type: application/json" -d "{\"id\":\"user${i}\",\"name\":\"student ${i}\", \"password\":\"${USER_PASSWORD}\"}" https://$A2_HOSTNAME/apis/iam/v2/users ;
done
