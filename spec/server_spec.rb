require File.expand_path(File.dirname(__FILE__)) + "/helper"

require 'arguments'
require 'tempfile'
require 'scruby/node'
require 'scruby/core_ext/array'
require 'scruby/core_ext/typed_array'
require 'scruby/bus'
require 'scruby/server'

include Scruby

Thread.abort_on_exception = true

describe Message do
  it "should encode array as Message Blob" do
    m = Message.new "/b_allocRead", 1, "path", 1, -1, ["/b_query", 1]
    m.encode.should == "/b_allocRead\000\000\000\000,isiib\000\000\000\000\000\001path\000\000\000\000\000\000\000\001\377\377\377\377\000\000\000\024/b_query\000\000\000\000,i\000\000\000\000\000\001"
  end
end

describe Server do
  describe "booting" do
    before { @server = Server.new }

    after do 
      @server.quit and sleep(0.3)
      @server.should_not be_running
    end

    it 'should boot' do 
      @server.boot
      @server.should be_running
    end

    it "should not reboot" do
      @server.boot
      lambda{ @server.boot }.should raise_error(Server::SCError)
    end

    it "should raise scsynth not found error" do
      lambda do 
        @server = Server.new(:path => 'not_scsynth')
        @server.path.should == 'not_scsynth'
        @server.boot 
      end.should raise_error(Server::SCError)
    end

    describe 'server list' do
      # it "should add server to server list" do
      #   Server.all.should include(@server)
      # end

      it "should remove server from server list" do
        @server.boot
        @server.quit
        Server.all.should be_empty
      end
    end
  end

  describe 'sending OSC' do
    before :all do
      @server = Server.new
      @server.boot
      @server.send "/dumpOSC", 3
      sleep 0.05
    end
    
    after :all do
      @server.quit
    end
    
    before do
      @server.flush
    end
    
    it "should send dump" do
      @server.send "/dumpOSC", 1
      sleep 0.1
      @server.output.should =~ %r{/dumpOSC}
    end
    
    it "should send synthdef" do
      sdef = mock 'sdef', :encode => [83, 67, 103, 102, 0, 0, 0, 1, 0, 1, 4, 104, 111, 108, 97, 0, 2, 67, -36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 6, 83, 105, 110, 79, 115, 99, 2, 0, 2, 0, 1, 0, 0, -1, -1, 0, 0, -1, -1, 0, 1, 2, 0, 0 ].pack('C*')
      @server.send_synth_def sdef
      sleep 0.1
      @server.output.should =~ %r{\[ "#bundle", 1,\s+\[ "/d_recv", DATA\[56\], 0 \]\n\]}
    end
    
    it "should send synthdef2" do
      sdef = mock 'sdef', :encode => [83, 67, 103, 102, 0, 0, 0, 1, 0, 1, 3, 114, 101, 99, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 6, 98, 117, 102, 110, 117, 109, 0, 0, 0, 3, 7, 67, 111, 110, 116, 114, 111, 108, 1, 0, 0, 0, 1, 0, 0, 1, 2, 73, 110, 2, 0, 1, 0, 2, 0, 0, 255, 255, 0, 0, 2, 2, 7, 68, 105, 115, 107, 79, 117, 116, 2, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0].pack('C*')
      @server.send_synth_def sdef
      sleep 0.1
      @server.output.should =~ %r{\[ "#bundle", 1, \n\s*\[ "/d_recv", DATA\[100\], 0 \]\n\]}
    end
  end

  describe 'allocation' do
    shared_examples_for 'allocates' do
      it 'should allocate elements' do
        @server.allocate @kind, (1..@max_size).map{ mock('allocatable') }
        @server.instance_variable_get(@collection).compact.should have(@max_size).elements 
      end

      it "should not allow more than determined elements" do
        lambda do
          @server.allocate @kind, (1..@max_size+1).map{mock('allocatable')}
        end.should raise_error(SCError)
      end

      describe 'allocating by appending' do
        before do
          @server.instance_variable_set @collection, [mock('allocated'), nil, nil, nil, mock('allocated')]
        end

        describe 'allocating to lowest available index' do
          before { @server.allocate @kind, @allocatable = mock('allocatable') }
          it { @server.instance_variable_get(@collection)[1].should == @allocatable }
          it { @server.instance_variable_get(@collection).compact.should have(3).elements }
        end

        describe 'allocating elements in contiguous indices' do
          before { @server.allocate @kind, (1..3).map{ mock('allocatable') } }
          it { @server.instance_variable_get(@collection).compact.should have(5).elements }
          it { @server.instance_variable_get(@collection)[1..3].each { |slot| slot.should_not be_nil } }
        end

        describe 'allocating elements by appending when no contigous nil indices are available' do
          before { @server.allocate @kind, (1..4).map{ mock('allocatable') } }
          it { @server.instance_variable_get(@collection).compact.should have(6).elements }
          it { @server.instance_variable_get(@collection)[5..9].each { |slot| slot.should_not be_nil } }
        end

        it 'should not allowing allocating more than available contiguous indices' do
          lambda do
            @server.allocate @kind, (1..@max_size - 2).map{ mock('allocatable') }
          end.should raise_error(SCError)
        end
      end
    end

    before do
      @server = Server.new
    end

    describe 'buffers allocation' do
      before do
        @kind        = :audio_buses
        @collection  = :@audio_buses
        @max_size    = 8
        @index_start = 0
      end
      it_should_behave_like 'allocates'
    end

    describe 'buffers allocation' do
      before do
        @kind        = :control_buses
        @collection  = :@control_buses
        @max_size    = 8
        @index_start = 0
      end
      it_should_behave_like 'allocates'
    end

    describe 'buffers allocation' do
      before do
        @kind        = :buffers
        @collection  = :@buffers
        @max_size    = 1024
        @index_start = 0
      end
      it_should_behave_like 'allocates'
    end
  end
end 
