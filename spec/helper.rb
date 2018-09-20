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

module Scruby
  module Test

    SOUND_DIR = File.expand_path(File.join('..', 'fixtures', 'sounds'), __FILE__)
    DEFAULT_SLEEP = 0.1 # 100 msec for threads to sync up

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
