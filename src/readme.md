# Auth this, Auth that

## JWT

Need to set an environment variable just for testing.
It can be committed to repo, no worries.

Steps:

1. `bundle install`
1. `[bundle exec] rackup jwt_id_server.ru` to start the jwt id server. The bundle exec is for people using `rbenv` instead of `rvm`.
1. `./rack_jwt_test.sh` will post to the server.

## Basic auth

- `rackup rack_basic_auth.ru` to start the server
- `./rack_basic_auth_test.sh` for the client
