require 'rack'
require 'base64'
require 'pry-nav'
require 'rspec/autorun' if ENV['RACK_TEST']

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
    username, password = userpass.split(':')
  end

  # TODO: clean this whole thing up, take out the `puts`
  # add in logging.
  def call(env)
    # TODO: Refactor into function
    auth_header = env["HTTP_AUTHORIZATION"]

    username, password = userpass(auth_header)
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
    [200, {"Content-Type" => "text/plain"}, ["Hello #{username}"] ]
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

run BasicAuth.new
