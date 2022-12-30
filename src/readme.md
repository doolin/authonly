# Auth this, Auth that

## JWT

Need to set an environment variable just for testing.
It can be committed to repo, no worries.

Steps:

1. `bundle install`
1. `[bundle exec] rackup jwt_id_server.ru` to start the jwt id server. The bundle exec is for people using `rbenv` instead of `rvm`.
1. `./rack_jwt_test.sh` will post to the server.

## Basic auth rails demo

- Rails server: `rackup rack_basic_auth_server.ru`
- Bash client: `./rack_basic_auth_client.sh`


