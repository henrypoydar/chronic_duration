require 'rubygems'
require 'bundler/setup'
require 'chronic_duration'

RSpec.configure do |config|
  config.color = true
  config.formatter = :progress
end