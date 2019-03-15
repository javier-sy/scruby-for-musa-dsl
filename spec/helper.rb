require 'rspec'
require 'yaml'
require 'ruby-osc'

require 'pry'

require 'scruby-for-musa-dsl/core_ext/object'
require 'scruby-for-musa-dsl/core_ext/array'
require 'scruby-for-musa-dsl/core_ext/numeric'
require 'scruby-for-musa-dsl/core_ext/integer'
require 'scruby-for-musa-dsl/core_ext/proc'
require 'scruby-for-musa-dsl/core_ext/string'
require 'scruby-for-musa-dsl/core_ext/symbol'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = [:should, :expect]
  end
end

module Scruby4MusaDSL
  module Test
    SOUND_DIR = File.expand_path(File.join('..', 'fixtures', 'sounds'), __FILE__)
    DEFAULT_SLEEP = 0.1 # 100 msec for threads to sync up
  end
end

def wait
  sleep Scruby4MusaDSL::Test::DEFAULT_SLEEP
end

def unwind(queue)
  $stdout.flush
  res = ''
  1.upto(queue.size) { res += queue.pop }
  res
end
