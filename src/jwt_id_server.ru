require 'rack'
require 'pry-nav'
require 'thin'
require 'jwt'
require 'base64'
require 'json'
require 'rspec'

# TODO: at the very least, get this thing returning a valid JWT.
# I want to see something in the header which looks like
# Authorization: Bearer <token>

# Example taken from https://en.wikipedia.org/wiki/JSON_Web_Token
class JwtServer
  SECRET = ENV['JWT_TEST_SECRET'] || 'secretkey'

  def call(env)
    # binding.pry
    [200, {"Content-Type" => "text/html; charset=utf-8"}, ["Hello World"]]
  end
end

# TODO: try the following
run JwtServer.new

# https://thoughtbot.com/upcase/videos/rack
# Rack::Handler::Thin.run Foo.new

# Also from https://thoughtbot.com/upcase/videos/rack
# app = -> (env) do
#  [ 200, { "Content-Type" => "text/plain" }, env ]
# end
# Rack::Handler::Thin.run app
