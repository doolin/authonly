require 'rack'
require 'pry-nav'
require 'thin'
require 'jwt'
require 'json'
require 'rspec'

# TODO: at the very least, get this thing returning a valid JWT.
# I want to see something in the header which looks like
# Authorization: Bearer: <token>

# Example taken from https://en.wikipedia.org/wiki/JSON_Web_Token
class Foo
  SECRET = ENV['JWT_TEST_SECRET'] || 'secretkey'

  # TODO: make this a valid JWT header
  def header
    {
      "alg" => "HS256",
      "typ" => "JWT"
  }.to_json
  end

  # TODO: make this a valid JWT payload
  def payload
    {
      "loggedInAs" => "admin",
      "iat" => 1422779638
  }.to_json
  end

  def prefix
    "#{header}.#{payload}"
  end

  # TODO: make this a valid JWT secret, whatever that means
  def secret
    "secret"
  end

  def token
    "#{prefix}.#{secret}"
  end

  def call(env)
    # binding.pry
    [200, {"Content-Type" => "text/html; charset=utf-8"}, ["Hello World"]]
  end
end

# TODO: try the following
# run Foo.new

# https://thoughtbot.com/upcase/videos/rack
# Rack::Handler::Thin.run Foo.new

# Also from https://thoughtbot.com/upcase/videos/rack
# app = -> (env) do
#  [ 200, { "Content-Type" => "text/plain" }, env ]
# end
# Rack::Handler::Thin.run app

RSpec.describe Foo do
  describe '#header' do
    it 'return header in json format' do
      expected = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}"
      expect(described_class.new.header).to eq expected
    end
  end

  describe '#payload' do
    it 'returns payload in json format' do
      expected = "{\"loggedInAs\":\"admin\",\"iat\":1422779638}"
      expect(described_class.new.payload).to eq expected
    end
  end
end