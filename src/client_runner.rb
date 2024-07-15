#!/usr/bin/env ruby
# frozen_string_literal: true

require 'colorize'
require 'cli/ui'


def rack_basic_auth(_args)
  puts 'Rack basic auth'
end

def jwt(_args)
  puts 'JWT'
end

CLI::UI::Prompt.instructions_color = CLI::UI::Color::GRAY

# rubocop:disable Performance/MethodObjectAsBlock
CLI::UI::Prompt.ask('Which server?') do |handler|
  handler.option('Rack basic auth', &method(:rack_basic_auth)) 
  handler.option('JWT', &method(:jwt))
end
# rubocop:enable Performance/MethodObjectAsBlock
