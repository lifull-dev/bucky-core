# frozen_string_literal: true

# Dir[File.join(File.dirname(__FILE__), '../lib/**/*.rb')].each { |f| require f }
require 'simplecov'
require 'simplecov-console'

# Save to CircleCI's artifacts directory if we're on CircleCI
if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], 'coverage')
  SimpleCov.coverage_dir(dir)
end

SimpleCov::Formatter::Console.table_options = { max_width: 170 }
SimpleCov.formatter = SimpleCov::Formatter::Console

SimpleCov.start do
  add_filter 'spec/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
