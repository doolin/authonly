#!/bin/bash

# Must use bash to get `echo -n` to work correctly.
encoded=$(echo -n "username1:password" | base64)
echo $encoded
# TODO: the -d flag is causing an error, and I don't think it should
# echo $encoded | base64 -d
#
# -I displays headers
# curl -v -i -I -X GET -w "%{stderr}{\"status\": \"%{http_code}\", \"body\":\"%{stdout}\"}"\
#      -H "Authorization: Basic $encoded" http://localhost:9292/

curl -v -i GET -w "%{stderr}{\"status\": \"%{http_code}\", \"body\":\"%{stdout}\"}" \
     -H "Authorization: Basic $encoded" http://localhost:9998/
