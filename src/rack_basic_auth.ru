require 'rack'
require 'base64'
require 'pry-nav'

class BasicAuth
  def userpass(basic_auth_value)
    # TODO: delete doesn't work here, which is an interesting topic for another day.
    # userpass_encoded = auth_header.delete('Basic ')

    # Rails does it like this for Basic Auth:
    # https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/metal/http_authentication.rb#L119
    # def auth_param(request)
    #   request.authorization.to_s.split(" ", 2).second
    # end
    #
    # For Rails Token Auth:
    # gsub(/^Digest\s+/, "")
    #
    # Doing my way here.
    userpass_encoded = auth_header.sub(/^Basic\s+/, '')
    userpass = Base64.decode64 userpass_encoded
    username, password = userpass.split(':')
  end

  def call(env)
    # TODO: Refactor into function
    auth_header = env["HTTP_AUTHORIZATION"]
    # TODO: delete doesn't work here, which is an interesting topic for another day.
    # userpass_encoded = auth_header.delete('Basic ')
    userpass_encoded = auth_header.sub(/^Basic\ /, '')
    userpass = Base64.decode64 userpass_encoded
    username, password = userpass.split(':')

    puts "Value of the Authorization field: #{auth_header}"
    puts "Decoded Authorization: #{userpass}"
    puts "username: #{username}, password: #{password}"

    # TODO: Implement the Basic Auth system, returning 200 for success,
    # 401 for unauthorized.
    # binding.pry
    [200, {"Content-Type" => "text/html; charset=utf-8"}, ["Hello World\n"]]
  end
end

# TODO: write some specs for this file.
# TODO: create an actual testing framework for these examples.

run BasicAuth.new