# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bucky/version'

Gem::Specification.new do |spec|
  spec.name          = 'bucky-core'
  spec.version       = Bucky::Version::VERSION
  spec.authors       = %w[NaotoKishino HikaruFukuzawa SeiyaSato NaokiNakano RikiyaHikimochi JyeRuey]
  spec.email         = ['KishinoNaoto@lifull.com']

  spec.summary = 'System testing framework for WEB application.'
  spec.description = 'Bucky is a testing framework that supports web system testing life cycle.'

  spec.required_rubygems_version = '>= 2.4.2'
  spec.homepage      = 'https://github.com/lifull-dev/bucky-core'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r{^(test|spec|features)/})
  }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'awesome_print',  '~> 1.8'
  spec.add_development_dependency 'bundler',        '~> 1.15'
  spec.add_development_dependency 'hirb',           '~> 0.7'
  spec.add_development_dependency 'pry',            '~> 0.10'
  spec.add_development_dependency 'pry-byebug',     '~> 3.4'
  spec.add_development_dependency 'pry-stack_explorer', '~> 0.4'
  spec.add_development_dependency 'rake',           '~> 12'
  spec.add_development_dependency 'rspec',          '~> 3.6'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.3'
  spec.add_development_dependency 'rubocop',        '~> 0.54'
  spec.add_development_dependency 'simplecov-console', '~> 0.4.2'

  spec.add_runtime_dependency 'color_echo',         '~> 3.1'
  spec.add_runtime_dependency 'json',               '~> 2.1'
  spec.add_runtime_dependency 'nokogiri',           '~> 1.8'
  spec.add_runtime_dependency 'parallel',           '~> 1.11'
  spec.add_runtime_dependency 'ruby-mysql',         '~> 2.9'
  spec.add_runtime_dependency 'selenium-webdriver', '~> 3.4'
  spec.add_runtime_dependency 'sequel',             '~> 4.48'
  spec.add_runtime_dependency 'test-unit',          '~> 3.2'
end
