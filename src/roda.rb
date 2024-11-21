#!/usr/bin/env ruby

require 'roda'

# The simplest possible Roda application.
class App < Roda
  route do |r|
    r.root do
      'Hello, World!'
    end
  end
end

# Start the Rack server directly
if $PROGRAM_NAME == __FILE__
  require 'rack'
  Rack::Server.start(app: App.freeze.app, Port: 8765)
end
