# -*- coding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hutte/version'

Gem::Specification.new do |spec|
  spec.name          = "hutte"
  spec.version       = Hutte::VERSION
  spec.authors       = ['Bastien Léonard']
  spec.email         = ['bastien.leonard@gmail.com']
  spec.summary       = %q{Simple SSH execution in Ruby, heavily based on Python's Fabric.}
#  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = 'https://github.com/bastienleonard/hutte'
  spec.license       = 'BSD'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'net-ssh'
  spec.add_dependency 'highline'
  spec.add_dependency 'open4'
end
