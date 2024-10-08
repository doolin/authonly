# frozen_string_literal: true

# Run this file with
# $ rackup rails_basic_auth_server.ru -p 9999

# This is all for later, needs to be updated from the article at
# https://christoph.luppri.ch/articles/rails/single-file-rails-applications-for-fun-and-bug-reporting/
# begin
#  require "bundler/inline"
# rescue LoadError => e
#  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
#  raise e
# end

# gemfile(true) do
#  source "https://rubygems.org"
#
#  gem "rails"
#  gem "pg"
#  gem "factory_girl_rails"
# end

# This comes from
# https://medium.com/hash32/rack-and-rails-applications-b42922d61146
require 'rails'
require 'action_controller/railtie'

# TODO: Read through Rails source code to understand how the various
# controller actions for authentication are implemented.
# TODO: Implement simple logging.
# TODO: try invalid login

# Rails.logger = Logger.new(STDOUT)

# Our main Rails application
class SingleFile < Rails::Application
  config.session_store :cookie_store, key: '_session'
  config.secret_key_base = '7893aeb3427daf48502ba09ff695da9ceb3c27daf48b0bba09df'
  Rails.logger = Logger.new($stdout)
end

# What we want to serve in response to a query
class IndexPage
  def self.hello_world
    "<h1>Hello World!</h1> <p>I'm just a single file Rails application</p>"
  end
end

# Make rubocop happy
class ApplicationController < ActionController::Base; end

# Rails will automatically find this controller and index method from the defined route.
class PagesController < ApplicationController
  # https://medium.com/weareevermore/how-to-add-http-basic-authentication-to-your-rails-application-e4e4d5b958d9
  # TODO: Explain how the controller returns a 401 when this macro fails.
  http_basic_authenticate_with name: 'username', password: 'password'

  # This is what to do when logging is necessary.
  # before_action :authenticate

  def index
    render inline: IndexPage.hello_world # rubocop:disable Rails/RenderInline
  end

  private

  def authenticate
    # TODO: explain how the controller returns 401 when this method fails.
    authenticate_or_request_with_http_basic do |username, password|
      username == 'username' && password == 'password'
    end
  end
end

SingleFile.routes.draw do
  root to: 'pages#index'
end

run SingleFile
