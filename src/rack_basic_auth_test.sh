#!/bin/bash

# Must use bash to get `echo -n` to work correctly.
encoded=$(echo -n "username:password" | base64)
echo $encoded
echo $encoded | base64 -d
curl -X GET -H "Authorization: Basic $encoded" http://localhost:9292/
