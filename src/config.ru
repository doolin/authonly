

# This is all for later, needs to be updated from the article at
# https://christoph.luppri.ch/articles/rails/single-file-rails-applications-for-fun-and-bug-reporting/
#begin
#  require "bundler/inline"
#rescue LoadError => e
#  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
#  raise e
#end

#gemfile(true) do
#  source "https://rubygems.org"
#
#  gem "rails"
#  gem "pg"
#  gem "factory_girl_rails"
#end


# This comes from
# https://medium.com/hash32/rack-and-rails-applications-b42922d61146
require 'rails'
require "action_controller/railtie"

# Run this file with
# $ rackup config.ru

class SingleFile < Rails::Application
  config.session_store :cookie_store, :key => '_session'
  config.secret_key_base = '7893aeb3427daf48502ba09ff695da9ceb3c27daf48b0bba09df'
  Rails.logger = Logger.new($stdout)
end

class PagesController < ActionController::Base
  # https://medium.com/weareevermore/how-to-add-http-basic-authentication-to-your-rails-application-e4e4d5b958d9
  http_basic_authenticate_with name: 'username', password: 'password'

  def index
    render inline: "<h1>Hello World!</h1> <p>I'm just a single file Rails application</p>"
  end
end

SingleFile.routes.draw do
  root to: "pages#index"
end

run SingleFile
