#!/usr/bin/env bash

REPO_ENDPOINT="https://api.travis-ci.org/repo/cloudinary-misha%2Fnode-tests-lab/requests"
TOKEN=$(travis token)
BODY='{
  "request": {
    "branch":"master",
    "config": {
      "merge_mode": "merge",
      "env": {
        "CUSTOM_VAR": "yes"
      }
    }
  }
}'

echo $BODY

curl -s -X POST \
   -H "Content-Type: application/json" \
   -H "Accept: application/json" \
   -H "Travis-API-Version: 3" \
   -H "Authorization: token $TOKEN" \
   -d "$BODY" \
   $REPO_ENDPOINT