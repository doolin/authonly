#!/bin/bash

source ./helpers.sh

# Must use bash to get `echo -n` to work correctly.
encoded=$(echo -n "username1:password" | base64)
infotext $encoded

# TODO: the -d flag is causing an error, and I don't think it should
# echo $encoded | base64 -d
#
# -I displays headers
# curl -v -i -I -X GET -w "%{stderr}{\"status\": \"%{http_code}\", \"body\":\"%{stdout}\"}"\
#      -H "Authorization: Basic $encoded" http://localhost:9292/

curl -v -i -w "%{stderr}{\"status\": \"%{http_code}\", \"body\":\"%{stdout}\"}" \
     -H "Authorization: Basic $encoded" http://localhost:9998/

echo ""
press_enter

infotext "Raw response:"
response=$(curl -s -X GET -H "Authorization: Basic $encoded" http://localhost:9998/)
echo "Raw response:"
echo "$response"

infotext "Parsed response:"
response=$(curl -s -X GET -H "Authorization: Basic $encoded" http://localhost:9998/)
status_code=$(echo "$response" | jq -r '.status')
body_content=$(echo "$response" | jq -r '.body')
echo "Status Code: $status_code"
echo "Body Content: $body_content"