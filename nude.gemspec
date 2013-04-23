# -*- coding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nude/version'

Gem::Specification.new do |spec|
  spec.name          = 'nude'
  spec.version       = Nude::VERSION
  spec.authors       = ['Kazuya Takeshima']
  spec.email         = ['mail@mitukiii.jp']
  spec.description   = %q{Port of nude.js to Ruby.}
  spec.summary       = %q{Port of nude.js to Ruby.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rmagick'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'growl'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
end
