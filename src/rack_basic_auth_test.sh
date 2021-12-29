#!/bin/bash

# Must use bash to get `echo -n` to work correctly.
encoded=$(echo -n "username1:password" | base64)
echo $encoded
# TODO: the -d flag is causing an error, and I don't think it should
# echo $encoded | base64 -d
#
# -I displays headers
curl -I -X GET -H "Authorization: Basic $encoded" http://localhost:9292/
