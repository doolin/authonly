#!/bin/sh

echo "test"

encoded=`echo "username:password" | base64`

echo $encoded
echo "Authorization: Basic $encoded"

curl -X GET -H "Authorization: Basic $encoded" http://localhost:9292/
