# Auth this, Auth that

The idea driving the repository is to have an implementation library of various low level
authentication schemes useful for reference and learning.

## Installing

Not much to do. Ensure the Ruby version is installed, then run `bundle install` and
everything should be good to go. Each of the services can be run independently, and
queried independently with its own Ruby or sh script.

### Dockerized

If you have docker installed, all the services are bundled with a docker compose file.

## TL;DR

If the installation proceeded correctly, `cd src` and `./client_runner.rb` will present
a menu of choices to select.

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

TBD.
