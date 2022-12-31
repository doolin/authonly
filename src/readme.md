# Auth this, Auth that

## Installing

Not much to do. Ensure the Ruby version is installed, then run `bundle install` and
everything should be good to go.

## JWT

Need to set an environment variable just for testing.
It can be committed to repo, no worries.


- Start the server:`[bundle exec] rackup jwt_id_server.ru`. The bundle exec is for people using `rbenv` instead of `rvm`.
- Run the Bash client: `./rack_jwt_test.sh`, which will post to the server.

## Basic auth

### Rack demo

- Rack server: `rackup rack_basic_auth_server.ru`
- Bash client: `./rack_basic_auth_client.sh`

### Rails demo

- Rack server: `rackup rails_basic_auth_server.ru`
- Bash client: `./rails_basic_auth_client.sh`


## Testing

