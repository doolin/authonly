# Hit the rack endpoint to acquire the jwt. We'll assume no other authentication
# for now.
#
# I've already got a question: the JWT identity server uses the same secret/key pair
# for all users...?
#  * How does an application know what's allowed and what's not?
#  * This seems to be "flat" roles, iow, authorization is same for all clients. What
#  * am I missing?
#  * Bigger question: am I going to have time to finish this little project while on PTO?

# You can add -H "Content-Type: application/json" header value to Post the JSON data
 # to curl command line.

# For example, I have an API URL https://api.example.com/v2/login, that is used to
# authenticate the application. Now passing the username and password in JSON format
# using the curl command line tool.

# curl -X POST -H "Content-Type: application/json" \
#  -d '{"username":"abc","password":"abc"}' \
#  https://api.example.com/v2/login

# You can also write the username and password in a user.json file. Now use this file
# to pass the JSON data to curl command line.

# curl -X POST -H "Content-Type: application/json" \
#  -d @user.json \
#  https://api.example.com/v2/login
