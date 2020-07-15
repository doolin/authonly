require 'rack'
require 'pry-nav'
require 'thin'
require 'dbm'

# TODO: Implement DBM for simple password storage
# https://ruby-doc.org/stdlib-2.7.1/libdoc/dbm/rdoc/DBM.html
# require 'dbm'
# db = DBM.open('rfcs', 0666, DBM::WRCREAT)
#
# Possibly try PStore instead:
# https://ruby-doc.org/stdlib-2.7.1/libdoc/pstore/rdoc/PStore.html
# https://ruby-doc.org/core-2.7.1/Marshal.html

# TODO: implement simple sign up with a user/pass coming in as a POST
#
# This will require:
# * Understanding how Rack deals with GET versus POST requests
# * Processing the user/pass parameters. Should these come in as json,
#   or some other format in the post body?
# * Check the pw store, creating the user/pass entry if not already there.
# * Send back a JWT with appropriate header and claims

# Example taken from https://en.wikipedia.org/wiki/JSON_Web_Token
class JwtServer
  SECRET = ENV['JWT_TEST_SECRET'] || 'secretkey'

  def initialize
    db = DBM.open('rfcs', 0666, DBM::WRCREAT)
    db['822'] = 'Standard for the Format of ARPA Internet Text Messages'
    db['1123'] = 'Requirements for Internet Hosts - Application and Support'
    db['3068'] = 'An Anycast Prefix for 6to4 Relay Routers'
    puts db['822']
    puts DBM::VERSION
    db.close
  end

  def call(env)
    payload = {
      "loggedInAs": "admin",
      "iat": 1422779638
    }
    jwt_token = JWT.encode(payload, JwtServer::SECRET, 'HS256', { typ: 'JWT' })

    headers = {
      "Content-Type" => "text/html; charset=utf-8",
      "Authorization" => "Bearer #{jwt_token}"
    }

    # [200, {"Content-Type" => "text/html; charset=utf-8"}, ["Hello World"]]
    [200, headers, ["Hello World"]]
  end
end


run JwtServer.new

# https://thoughtbot.com/upcase/videos/rack
# Rack::Handler::Thin.run Foo.new

# Also from https://thoughtbot.com/upcase/videos/rack
# app = -> (env) do
#  [ 200, { "Content-Type" => "text/plain" }, env ]
# end
# Rack::Handler::Thin.run app
