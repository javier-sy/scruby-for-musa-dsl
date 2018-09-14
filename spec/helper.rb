require "rubygems" 
require "rspec" 
require 'arguments'
require 'yaml'
require 'ruby-osc'
begin
  require 'byebug'
rescue LoadError
  warn('debugging will not be availabe')
end

require 'pry'

$:.unshift( File.dirname(__FILE__) + '/../lib' ) 
$:.unshift File.dirname(__FILE__)

require "scruby/core_ext/object"
require "scruby/core_ext/array"
require "scruby/core_ext/numeric"
require "scruby/core_ext/integer"
require "scruby/core_ext/proc"
require "scruby/core_ext/string"
require "scruby/core_ext/symbol"

# Support old-style `should` and `stub` monkeypatches (for now)
RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.syntax = :should
  end

  config.expect_with :rspec do |c|
    c.syntax = :should
  end
end

module Scruby
  module Test

    SOUND_DIR = File.expand_path(File.join('..', 'fixtures', 'sounds'), __FILE__)

  end
end
