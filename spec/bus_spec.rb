require File.expand_path(File.dirname(__FILE__)) + "/helper"

require 'tempfile'

require "scruby/core_ext/numeric"
require "scruby/bus"
require "scruby/server"

include Scruby

describe Bus do
  before do
    @server = mock('Server', :audio_buses => [], :control_buses => [])      
    @server.stub!(:buses) { |type| @server.send "#{type}_buses" }
  end

  describe 'instance' do
    shared_examples_for 'bus' do
      it { @bus.server.should == @server }
      it { @bus.rate.should   == @rate }
      it { @bus.index.should  == 0 }
      it { @server.buses(@rate).should include @bus }

      describe 'freeing' do
        before { @bus.free }
        it { @server.buses(@rate).should_not include @audio }
        it { @bus.index.should == nil }
      end
    end

    describe AudioBus do
      before do
        @bus    = AudioBus.new @server
        @server.audio_buses << @bus
        @rate   = :audio
      end

      it_should_behave_like 'bus'
    end

    describe ControlBus do
      before do
        @bus    = ControlBus.new @server
        @server.control_buses << @bus
        @rate   = :control
      end

      it { @bus.to_map.should == "c0" }
      it_should_behave_like 'bus'
    end
  end

  describe 'class' do
    shared_examples_for 'allocates multichannel buses' do
      before do
        @server.stub!(:allocate) { |type, buses| @server.send(type).push *buses }
        @bus = subject.allocate_buses @server, 4
      end

      it { @bus.should be_a Bus }
      it { @bus.index.should == 0 }
      it { @server.buses(subject::RATE).should have(4).buses }
      it { @bus.channels.should == 4 }
      it { @server.buses(subject::RATE).each { |bus| bus.main_bus.should == @bus } } 
    end

    describe AudioBus do
      subject { AudioBus }
      it { subject::RATE.should == :audio }
      it_should_behave_like 'allocates multichannel buses'
    end

    describe ControlBus do
      subject { ControlBus }
      it { subject::RATE.should == :control }
      it_should_behave_like 'allocates multichannel buses'
    end
  end

  # describe 'instantiation' do
  #   it "should be hardware out" do
  #     @server.audio_buses[0].should be_audio_out
  #     @audio.should_not be_audio_out
  #   end
  # end
  
  # describe "messaging" do
  #   before :all do
  #     @server = Server.new
  #     @server.boot
  #     @server.send "/dumpOSC", 3
  #     @bus = Bus.control @server, 4
  #     sleep 0.05
  #   end    

  #   after :all do
  #     @server.quit
  #   end
  #   
  #   before do
  #     @server.flush
  #   end
  #   
  #   describe 'set' do
  #     it "should send set message with one value" do
  #       @bus.set 101
  #       sleep 0.01
  #       @server.output.should =~ %r{\[ "/c_set", #{@bus.index}, 101 \]}
  #     end
  #     
  #     it "should accept value list and send set with them" do
  #       @bus.set 101, 202
  #       sleep 0.01
  #       @server.output.should =~ %r{\[ "/c_set", #{@bus.index}, 101, #{@bus.index + 1}, 202 \]}
  #     end
  #     
  #     it "should accept an array and send set with them" do
  #       @bus.set [101, 202]
  #       sleep 0.01
  #       @server.output.should =~ %r{\[ "/c_set", #{@bus.index}, 101, #{@bus.index + 1}, 202 \]}
  #     end
  #     
  #     it "should warn but not set if trying to set more values than channels" do
  #       @bus.should_receive(:warn).with("You tried to set 5 values for bus #{@bus.index} that only has 4 channels, extra values are ignored.")
  #       @bus.set 101, 202, 303, 404, 505
  #       sleep 0.01
  #       @server.output.should =~ %r{\[ "/c_set", #{@bus.index }, 101, #{@bus.index + 1}, 202, #{@bus.index + 2}, 303, #{@bus.index + 3}, 404 \]}
  #     end
  #   end
  #   
  #   describe 'set' do
  #     it "should send fill just one channel" do
  #       @bus.fill 101, 1
  #       sleep 0.01
  #       @server.output.should =~ %r{\[ "/c_fill", #{@bus.index}, 1, 101 \]}
  #     end
  #     
  #     it "should fill all channels" do
  #       @bus.fill 101
  #       sleep 0.01
  #       @server.output.should =~ %r{\[ "/c_fill", #{@bus.index}, 4, 101 \]}
  #     end
  #     
  #     it "should raise error if trying to fill more than assigned channels" do
  #       @bus.should_receive(:warn).with("You tried to set 5 values for bus #{ @bus.index } that only has 4 channels, extra values are ignored.")
  #       @bus.fill 101, 5
  #       sleep 0.01
  #       @server.output.should =~ %r{\[ "/c_fill", #{@bus.index}, 4, 101 \]}
  #     end
  #   end
  #   
  #   describe 'get' do
  #     it "should send get message with one value"
  #     it "should send get message for various channels"
  #     it "should accept an array and send set with them"
  #     it "should raise error if trying to set more values than channels"
  #     it "should actually get the response from the server"
  #   end
  # end
end
