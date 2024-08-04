# frozen_string_literal: true

require 'rack'
require 'json'
require 'base64'
require 'redis'
# require 'rspec/autorun' if ENV['RACK_TEST']
require_relative 'token_bucket'

# Define middleware for implementing token bucket rate limiting
# This class will be added to the Rack middleware stack
# class RateLimit
# end

# class TokenBucket < RateLimit
# What this class needs to do:
# - Initialize with a bucket size
# - draw one token when a request is made, which is a decrememnt for the bucket value.
# - the bucket value needs to be persisted between requests.
# - the bucket value is incremented by one token per second.
# - the bucket value is capped at the bucket size, and no more tokens are added.
# - the bucket refreshed does not block the request, it is done in the background.

# class TokenBucket
#   attr_reader :bucket_size, :redis_key

#   def initialize(app, bucket_size:, redis_key:)
#     @app = app
#     @bucket_size = bucket_size
#     @redis_key = redis_key
#     @redis = Redis.new(host: 'redis', port: 6379)

#     # Set the initial bucket value in Redis if not already set
#     @redis.setnx(@redis_key, bucket_size)
#     start_background_refill
#   end

#   def call(env)
#     if draw_token
#       @app.call(env)
#     else
#       [429, { 'Content-Type' => 'text/plain' }, ['Rate limit exceeded']]
#     end
#   end

#   private

#   def draw_token
#     current_tokens = @redis.get(@redis_key).to_i
#     if current_tokens > 0
#       @redis.decr(@redis_key)
#       true
#     else
#       false
#     end
#   end

#   def start_background_refill
#     Thread.new do
#       loop do
#         sleep(1)
#         refill_bucket
#       end
#     end
#   end

#   def refill_bucket
#     @redis.watch(@redis_key) do
#       current_tokens = @redis.get(@redis_key).to_i
#       if current_tokens < @bucket_size
#         @redis.multi do |multi|
#           multi.incr(@redis_key)
#         end
#       end
#     end
#   end
# end

# class TokenBucket
#   attr_accessor :bucket, :last_refreshed

#   def initialize(bucket_size)
#     @bucket = bucket_size
#     @last_refreshed = Time.now
#   end

#   def decrement_bucket
#     @bucket -= 1
#   end

#   def token_available?
#     bucket.positive?
#   end

#   def refresh_bucket
#     # If the bucket is full, don't add any more tokens.
#     return if @bucket == 4

#     # If the bucket is not full, add a token.
#     @bucket += 1
#   end

#   def call(env)
#     # Implement rate limiting here
#     puts "Rate limiting middleware called. Bucket size: #{@bucket}"

#     refresh_bucket

#     return [429, { 'Content-Type' => 'text/plain' }, ['Too Many Requests']] unless token_available?

#     decrement_bucket

#     @app.call(env)
#   end

# Old stuff
#   attr_accessor :app, :bucket

#   def initialize(app)
#     @app = app
#     @bucket = 4
#   end

#   def decrement_bucket
#     @bucket -= 1
#   end

#   def token_available?
#     bucket.positive?
#   end

#   def call(env)
#     # Implement rate limiting here
#     puts "Rate limiting middleware called. Bucket size: #{@bucket}"

#     return [429, { 'Content-Type' => 'text/plain' }, ['Too Many Requests']] unless token_available?

#     decrement_bucket

#     @app.call(env)
#   end
# end

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
  use TokenBucket, bucket_size: 1, refill_rate: 1, redis_key: 'new_rate_limit'
  run BasicAuth.new
end

run app
