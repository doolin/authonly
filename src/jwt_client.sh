# Hit the rack endpoint to acquire the jwt. We'll assume no other authentication
# for now.
#
# I've already got a question: the JWT identity server uses the same secret/key pair
# for all users...?
#  * How does an application know what's allowed and what's not?
#  * This seems to be "flat" roles, iow, authorization is same for all clients. What
#  * am I missing?
#  * Bigger question: am I going to have time to finish this little project while on PTO?
