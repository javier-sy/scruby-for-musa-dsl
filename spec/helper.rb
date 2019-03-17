require 'rspec'
require 'yaml'
require 'ruby-osc'

require 'scruby/core_ext/object'
require 'scruby/core_ext/array'
require 'scruby/core_ext/numeric'
require 'scruby/core_ext/integer'
require 'scruby/core_ext/proc'
require 'scruby/core_ext/string'
require 'scruby/core_ext/symbol'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = [:should, :expect]
  end
end

module Scruby
  module Test
    SOUND_DIR = File.expand_path(File.join('..', 'fixtures', 'sounds'), __FILE__)
    DEFAULT_SLEEP = 0.2 # 200 msec for threads to sync up
  end
end

def wait
  sleep Scruby::Test::DEFAULT_SLEEP
end

def unwind(queue)
  $stdout.flush
  res = ''
  1.upto(queue.size) { res += queue.pop }
  res
end
