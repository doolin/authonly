#!/bin/bash

# This simple client makes an authorized request first,
# then a second unauthorized request.

# source ./ansi_colors.sh
source ./helpers.sh

function hcurl() {
    curl "$@" | pygmentize -l html
}

# Authorized request.
# Must use bash to get `echo -n` to work correctly.
authorized "Authorized"
encoded=$(echo -n "username:password" | base64)
hcurl -X GET -H "Authorization: Basic $encoded" http://localhost:9999/

press_enter

echo ""
echo ""
echo "------------------------------------------"
error "Unauthorized"
encoded=$(echo -n "username1:password1" | base64)
curl -v -H "Authorization: Basic $encoded" http://localhost:9999/
