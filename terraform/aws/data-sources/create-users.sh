#!/bin/bash
set -eu -o pipefail

for ((i=1; i<=$USER_COUNT; i++))
do
  echo "Creating user${i}" ;
  curl -k -H "api-token: $API_TOKEN" -H "Content-Type: application/json" -d "{\"id\":\"user${i}\",\"name\":\"student ${i}\", \"password\":\"${USER_PASSWORD}\"}" https://$A2_HOSTNAME/apis/iam/v2/users ;
  membership_id=$(curl -k -H "api-token: $API_TOKEN" -H "Content-Type: application/json" https://$A2_HOSTNAME/apis/iam/v2/users/user${i} | sed -n 's|.*"membership_id":"\([^"]*\)".*|\1|p') ;
  curl -k -H "api-token: $API_TOKEN" -H "Content-Type: application/json" -d "{\"membership_ids\":[\"$membership_id\"]}" https://$A2_HOSTNAME/apis/iam/v2/teams/editors/users:add ;
done
