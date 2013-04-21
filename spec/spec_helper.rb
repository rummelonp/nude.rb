# -*- coding: utf-8 -*-

unless ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

require 'nude'
require 'rspec'
