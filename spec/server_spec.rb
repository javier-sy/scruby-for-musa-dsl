require_relative 'helper'

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
    m.encode.bytes.should == "/b_allocRead\000\000\000\000,isiib\000\000\000\000\000\001path\000\000\000\000\000\000\000\001\377\377\377\377\000\000\000\024/b_query\000\000\000\000,i\000\000\000\000\000\001".bytes
  end
end

describe Server do
  describe "booting" do
    before :each do
      @server = Server.new
    end

    after :each do
      @server.quit
    end

    it "should not rise scynth not found error" do
      lambda{ @server.boot }.should_not raise_error
    end

    it "should not reboot" do
      @server.boot
      Thread.should_not_receive(:new)
      @server.boot
    end

    it "should remove server from server list" do
      Server.all.should include @server
      @server.boot
      @server.quit
      Server.all.should_not include @server
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
      sdef = double 'sdef', :encode => [ 83, 67, 103, 102, 0, 0, 0, 1, 0, 1, 4, 104, 111, 108, 97, 0, 2, 67, -36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 6, 83, 105, 110, 79, 115, 99, 2, 0, 2, 0, 1, 0, 0, -1, -1, 0, 0, -1, -1, 0, 1, 2, 0, 0 ].pack('C*')
      @server.send_synth_def sdef
      sleep 0.1
      @server.output.should =~ %r{\[ "#bundle", 1,\s+\[ "/d_recv", DATA\[56\], 0 \]\n\]}
    end

    it "should send synthdef2" do
      sdef = double 'sdef', :encode => [83, 67, 103, 102, 0, 0, 0, 1, 0, 1, 3, 114, 101, 99, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 6, 98, 117, 102, 110, 117, 109, 0, 0, 0, 3, 7, 67, 111, 110, 116, 114, 111, 108, 1, 0, 0, 0, 1, 0, 0, 1, 2, 73, 110, 2, 0, 1, 0, 2, 0, 0, 255, 255, 0, 0, 2, 2, 7, 68, 105, 115, 107, 79, 117, 116, 2, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0].pack('C*')
      @server.send_synth_def sdef
      sleep 0.1
      @server.output.should =~ %r{\[ "#bundle", 1, \n\s*\[ "/d_recv", DATA\[100\], 0 \]\n\]}
    end
  end

  shared_examples_for 'allocates' do
    it "should not allow more than @max_size elements" do
      lambda { @server.__send__( :allocate, @kind, (1..@max_size+1).map{ @class.new } ) }.should raise_error(SCError)
    end

    it "should try to allocate lowest nil slot" do
      @server.__send__(@kind).concat([nil, nil, @class.new, nil, nil, nil, @class.new])
      @server.__send__ :allocate, @kind, buffer = @class.new
      @server.__send__(@kind).index(buffer).should == @index_start
    end

    it "should allocate various elements in available contiguous indices" do
      @server.__send__(@kind).concat([nil, nil, @class.new, nil, nil, nil, @class.new])
      @server.__send__ :allocate, @kind, @class.new, @class.new, @class.new
      elements = @server.__send__(@kind)[@max_size-@allowed_elements..-1].compact
      elements.length.should eq 5
    end

    it "should allocate by appending various elements" do
      @server.__send__(@kind).concat([nil, nil, @class.new, nil, nil, nil, @class.new])
      @server.__send__ :allocate, @kind, @class.new, @class.new, @class.new, @class.new
      elements = @server.__send__(@kind)[@max_size-@allowed_elements..-1].compact
      elements.length.should eq 6
    end

    it "should not surpass the max buffer limit" do
      @server.__send__(:allocate, @kind, (1..@allowed_elements-2).map{ |i| @class.new if i % 2 == 0 } )
      lambda { @server.__send__ :allocate, @kind, @class.new, @class.new, @class.new }.should raise_error
    end

    it "should allocate by appending" do
      @server.__send__(:allocate, @kind, (1..@allowed_elements-3).map{ |i| @class.new if i % 2 == 0 } )
      @server.__send__ :allocate, @kind, @class.new, @class.new, @class.new
      @server.__send__(@kind).size.should == @max_size
    end
  end

  describe 'buffers allocation' do
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
