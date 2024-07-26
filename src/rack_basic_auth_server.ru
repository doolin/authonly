# frozen_string_literal: true

require 'rack'
require 'json'
require 'base64'
require 'redis'
require 'rspec/autorun' if ENV['RACK_TEST']

# Define middleware for implementing token bucket rate limiting
# This class will be added to the Rack middleware stack
class RateLimit
  attr_accessor :app, :bucket

  def initialize(app)
    @app = app
    @bucket = 4
  end

  def decrement_bucket
    @bucket -= 1
  end

  def token_available?
    bucket.positive?
  end

  def call(env)
    # Implement rate limiting here
    puts "Rate limiting middleware called. Bucket size: #{@bucket}"

    return [429, { 'Content-Type' => 'text/plain' }, ['Too Many Requests']] unless token_available?

    decrement_bucket

    @app.call(env)
  end
end

# Show a dumb way to implement basic auth in a rack application
class BasicAuth
  def userpass(auth_header)
    # Rails does it like this for Basic Auth:
    # https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/metal/http_authentication.rb#L119
    # def auth_param(request)
    #   request.authorization.to_s.split(" ", 2).second
    # end
    #
    # For Rails Token Auth:
    # gsub(/^Digest\s+/, "")
    #
    # Doing it my way here.
    userpass_encoded = auth_header.sub(/^Basic\s+/, '')
    userpass = Base64.decode64 userpass_encoded
    userpass.split(':')
  end

  def authenticated?(username, password)
    return true if username == 'username1' && password == 'password'

    false
  end

  # TODO: clean this whole thing up, take out the `puts`
  # add in logging.
  def call(env)
    # TODO: Refactor into function
    auth_header = env['HTTP_AUTHORIZATION']

    # Implement actual checking per TODO below
    username, password = userpass(auth_header)
    # binding.irb
    # puts "From userpass method, username: #{u}, password: #{p}"

    # TODO: Since the userpass method is working this needs rewritten.
    # userpass_encoded = auth_header.sub(/^Basic\ /, '')
    # userpass = Base64.decode64 userpass_encoded
    # username, password = userpass.split(':')

    # puts "Value of the Authorization field: #{auth_header}"
    # puts "Decoded Authorization: #{userpass}"
    # puts "username: #{username}, password: #{password}"

    # TODO: Implement the Basic Auth system, returning 200 for success,
    # 401 for unauthorized.
    # binding.pry
    # [200, {"Content-Type" => "text/plain; charset=utf-8"}, ["Hello #{username}"]]
    #
    # TODO: for some reason the body is not being returned.
    return unless authenticated?(username, password)

    response_body = {
      'salutations' => "Hello #{username}",
      'foo' => 'bar'
      # bucket_size: bucket
    }.to_json
    [200, { 'Content-Type' => 'application/json' }, [response_body]]
  end
end

# TODO: write some specs for this file.
# TODO: create an actual testing framework for these examples.
# Google search on "testing rackup file" returned
# http://testing-for-beginners.rubymonstas.org/rack_test/rack.html
#
# The challenge here is having both the convenience of specs written
# into the class file, and being able to run the class from elsehwere
# without the specs being invoked.

app = Rack::Builder.new do
  use RateLimit
  run BasicAuth.new
end

run app
