require_relative 'helper'

require 'scruby/core_ext/typed_array'
require 'scruby/node'
require 'scruby/group'
require 'scruby/bus'

require 'scruby/server'

include Scruby

describe Group do
  describe 'Server interaction' do
    before :all do
      @server = Server.new log: true
      @server.boot
      @server.send '/dumpOSC', 1
      @server.sync
    end

    after :all do
      @server.quit
    end

    before do
      @server.log.clear
      @group = Group.new @server
      @node  = Node.new @server
    end

    describe 'position' do
    end

    it 'should send free all message' do
      @group.free_all.should be_a(Group)
      @server.sync
      unwind(@server.log).should =~ %r{\[ "/g_freeAll", #{ @group.id } \]}
    end

    it 'should send deepFree message' do
      @group.deep_free.should be_a(Group)
      @server.sync
      unwind(@server.log).should =~ %r{\[ "/g_deepFree", #{ @group.id } \]}
    end

    it 'should send dump tree message' do
      @group.dump_tree.should be_a(Group)
      @server.sync
      unwind(@server.log).should =~ %r{\[ "/g_dumpTree", #{ @group.id }, 0 \]}
      @group.dump_tree true
      @server.sync
      unwind(@server.log).should =~ %r{\[ "/g_dumpTree", #{ @group.id }, 1 \]}
    end

    it 'should send dump tree message with arg'
    it 'should query_tree'
  end
end
