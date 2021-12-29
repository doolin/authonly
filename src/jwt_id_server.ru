require 'rack'
require 'pry-nav'
require 'thin'
require 'jwt'
require 'dbm'

# DBM is a simple key value story, probably built on
# Berkeley db. It's useful here for creating simple
# simulations of authentication management and flow.
# https://ruby-doc.org/stdlib-2.7.1/libdoc/dbm/rdoc/DBM.html
# require 'dbm'
# db = DBM.open('rfcs', 0666, DBM::WRCREAT)
#
# From irb:
# irb(main):001:0> require 'dbm'
# => true
# irb(main):002:0> db = DBM.open('rfcs')
# => #<DBM:0x0000000109b15918>
# irb(main):003:0> db['822']
# => "Standard for the Format of ARPA Internet Text Messages"
# irb(main):004:0>
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

# TODO: Look up form data, from Rack rubydoc
# https://www.rubydoc.info/gems/rack/Rack/Request/Helpers#body-instance_method
# #form_data? ⇒ Boolean
#
# Determine whether the request body contains form-data by checking
# the request Content-Type for one of the media-types: “application/x-www-form-urlencoded”
# or “multipart/form-data”. The list of form-data media types can be
# modified through the FORM_DATA_MEDIA_TYPES array.
#
# A request body is also assumed to contain form-data when no
# Content-Type header is provided and the request_method is POST.

# When reading Rack body object, it's a stream, hence reading it twice
# requires a rewind call:
# [11] pry(#<JwtServer>)> foo = req.body.read
# => ""
# [12] pry(#<JwtServer>)> foo
# => ""
# [13] pry(#<JwtServer>)> foo = req.body.rewind
# => nil
# [14] pry(#<JwtServer>)> foo = req.body.read
# => "{\"username\":\"abc\",\"password\":\"abc\"}"
# [15] pry(#<JwtServer>)> foo
# => "{\"username\":\"abc\",\"password\":\"abc\"}"
# [16] pry(#<JwtServer>)> foo = req.body.rewind
# => nil
# [17] pry(#<JwtServer>)> body = JSON.parse(req.body.read)
# => {"username"=>"abc", "password"=>"abc"}
# [18] pry(#<JwtServer>)> body
# => {"username"=>"abc", "password"=>"abc"}
# [19] pry(#<JwtServer>)>

# TODO: next step is to acquire the POST body and save user/pass in
# local db

# Example taken from https://en.wikipedia.org/wiki/JSON_Web_Token
class JwtServer
  SECRET = ENV['JWT_TEST_SECRET'] || 'secretkey'

  def store(params)
    db = DBM.open('rfcs', 0666, DBM::WRCREAT)
    username = params["username"]
    password = params["password"]

    puts "Received username: #{username}, password: #{password}"

    db['822'] = 'Standard for the Format of ARPA Internet Text Messages'
    db['1123'] = 'Requirements for Internet Hosts - Application and Support'
    db['3068'] = 'An Anycast Prefix for 6to4 Relay Routers'

    # TODO: does db[username] exist? Return if yes.
    db[username] = password

    # puts db[username]
    # puts DBM::VERSION
    db.close
  end

  def process_body(req)
    JSON.parse(req.body.read)
  end

  def call(env)
    req = Rack::Request.new(env)
    params = process_body(req)
    store(params)

    # binding.pry

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
    # [200, headers, ["Hello World\n"]]
    [200, headers, ["#{jwt_token}\n"]]
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
