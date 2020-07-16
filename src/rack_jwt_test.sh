#!/bin/bash

# Must use bash to get `echo -n` to work correctly.
# encoded=$(echo -n "username:password" | base64)
# echo $encoded
# echo $encoded | base64 -d
# curl -X GET -H "Authorization: Basic $encoded" http://localhost:9292/
# curl -I -X GET http://localhost:9292/


# You can add -H "Content-Type: application/json" header value to Post the JSON data to curl command line.

# For example, I have an API URL https://api.example.com/v2/login, that is used to
# authenticate the application. Now passing the username and password in JSON format
# using the curl command line tool.

curl -X POST -H "Content-Type: application/json" \
  -d '{"username":"abc","password":"abc"}' \
  http://localhost:9292/

# You can also write the username and password in a user.json file. Now use this file to pass the JSON data to curl command line.

# curl -X POST -H "Content-Type: application/json" \
#  -d @user.json \
#  http://localhost:9292/
