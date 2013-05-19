require File.dirname(__FILE__) + '/../spec_helper'
require 'minitest/spec'
require 'minitest/autorun'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end
