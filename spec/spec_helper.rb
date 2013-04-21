# -*- coding: utf-8 -*-

unless ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

require 'nude'
require 'rspec'

def image_dir
  File.join(File.expand_path(File.dirname(__FILE__)), 'images')
end

def image_path(image_name)
  File.join(image_dir, image_name)
end
