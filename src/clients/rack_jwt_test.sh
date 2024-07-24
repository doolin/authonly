#!/bin/bash

# Must use bash to get `echo -n` to work correctly.
# encoded=$(echo -n "username:password" | base64)
# echo $encoded
# echo $encoded | base64 -d
# curl -X GET -H "Authorization: Basic $encoded" http://localhost:9997/
# curl -I -X GET http://localhost:9997/

# You can add -H "Content-Type: application/json" header value to Post the JSON data to curl command line.

# For example, I have an API URL https://api.example.com/v2/login, that is used to
# authenticate the application. Now passing the username and password in JSON format
# using the curl command line tool.

explicit_json()
{
  echo "From explicit_json function..."
  curl -X POST -H "Content-Type: application/json" \
    -d '{"username":"abc","password":"abc"}' \
    http://localhost:9997/
}
# explicit_json

username=abc
password=123
# TODO: make a check for jo here.
if ! [ -x "$(command -v jo)" ]; then
  echo 'Error: json handling command "jo" is not installed, install with brew.' >&2
  exit 1
fi

# jo is a json handling utility for bash. Here is some discussion
# about jo and similar utilities:
# https://medium.com/swlh/different-ways-to-handle-json-in-a-linux-shell-81183bc2c9bc
json=`jo username=$username password=$password creation_date="$(date +%m-%d-%y)"`
curl -X POST -H "Content-Type: application/json" \
  -d "$json" \
  http://localhost:9997/

# You can also write the username and password in a user.json file.
# Now use this file to pass the JSON data to curl command line.
# curl -X POST -H "Content-Type: application/json" \
#  -d @user.json \
#  http://localhost:9997/
