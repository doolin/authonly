#!/bin/bash

# This simple client makes an authorized request first,
# then a second unauthorized request.

# Authorized request.
# Must use bash to get `echo -n` to work correctly.
encoded=$(echo -n "username:password" | base64)
# curl -X GET -H "Authorization: Basic $encoded" http://localhost:9292/
curl -X GET -H "Authorization: Basic $encoded" http://localhost:9292/

echo ""
echo "Unauthorized"
encoded=$(echo -n "username1:password1" | base64)
curl -v -X GET -H "Authorization: Basic $encoded" http://localhost:9292/
