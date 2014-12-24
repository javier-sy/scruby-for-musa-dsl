require "rubygems" 
require "rspec" 
require 'arguments'
require 'yaml'
require 'ruby-osc'

require 'pry'

$:.unshift( File.dirname(__FILE__) + '/../lib' ) 

require "scruby/core_ext/object"
require "scruby/core_ext/array"
require "scruby/core_ext/numeric"
require "scruby/core_ext/fixnum"
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
