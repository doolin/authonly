#!/usr/bin/env ruby
# frozen_string_literal: true

require 'colorize'
require 'open3'
require 'cli/ui'

def rack_basic_auth(_args)
  puts 'Rack basic auth'
  `./clients/rack_basic_auth_client.sh`
end

def jwt(_args)
  puts 'Rack JWT'
  script = './clients/rack_jwt_test.sh'

  stdout, stderr, status = Open3.capture3 script
end

CLI::UI::Prompt.instructions_color = CLI::UI::Color::GRAY
CLI::UI::Prompt.ask('Which server?') do |handler|
  handler.option('Rack basic auth', &method(:rack_basic_auth))
  handler.option('Rack JWT', &method(:jwt))
end
