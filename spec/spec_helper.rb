require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  # ENV["RAILS_ENV"] ||= 'test'
  # require File.expand_path("../../config/environment", __FILE__)
  # require 'rspec/rails'
  require 'jazz'
  require 'rspec/core'
  require 'rspec/expectations'

  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered = true
    config.filter_run :focus
  end
end

Spork.each_run do
  # Dir["#{Rails.root}/app/**/*.rb"].each {|f| load f}
  # Dir["#{Rails.root}/lib/**/*.rb"].each {|f| load f}
end
