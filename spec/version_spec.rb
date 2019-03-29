# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/bucky/version'

describe Bucky::Version do
  it 'has a version number' do
    expect(Bucky::Version::VERSION).not_to be_empty
  end
end
