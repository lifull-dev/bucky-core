# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bucky/version'

Gem::Specification.new do |spec|
  spec.name          = 'bucky-core'
  spec.version       = Bucky::Version::VERSION
  spec.authors       = %w[NaotoKishino HikaruFukuzawa SeiyaSato NaokiNakano RikiyaHikimochi JyeRuey]
  spec.email         = ['KishinoNaoto@lifull.com']

  spec.summary = 'System testing framework for web application.'
  spec.description = <<-DESCRIPTION
    Bucky-core can run test code which is written in YAML. End-to-End test (working with Selenium) and Linkstatus test (HTTP status check) are supported in default. Page object model pattern and page based element management is the main concept in Bucky-core. You can create scenarios and execute it easily by using Bucky-core.

  When working with Bucky-management, Bucky-core can also record test results. You can make test results visualization by using Bucky-management.
  DESCRIPTION
  spec.required_ruby_version = '>= 2.5'
  spec.homepage      = 'https://github.com/lifull-dev/bucky-core'
  spec.license       = 'Apache License 2.0'

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
  spec.add_development_dependency 'rake',           '~> 13'
  spec.add_development_dependency 'rspec',          '~> 3.6'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.3'
  spec.add_development_dependency 'rubocop', '~> 0.68.1'
  spec.add_development_dependency 'simplecov', '~> 0.15.1'
  spec.add_development_dependency 'simplecov-console', '~> 0.4.2'

  spec.add_runtime_dependency 'addressable', '~> 2.5'
  spec.add_runtime_dependency 'color_echo',         '~> 3.1'
  spec.add_runtime_dependency 'json',               '~> 2.3.0'
  spec.add_runtime_dependency 'nokogiri',           '>= 1.11.1', '< 1.13.0'
  spec.add_runtime_dependency 'parallel',           '~> 1.11'
  spec.add_runtime_dependency 'ruby-mysql',         '~> 2.9'
  spec.add_runtime_dependency 'selenium-webdriver', '~> 3.142'
  spec.add_runtime_dependency 'sequel',             '~> 4.48'
  spec.add_runtime_dependency 'test-unit',          '~> 3.2'
end
