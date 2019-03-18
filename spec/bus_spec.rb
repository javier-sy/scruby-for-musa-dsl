require_relative 'helper'

require 'tempfile'

require 'scruby/core_ext/numeric'
require 'scruby/bus'
require 'scruby/server'

include Scruby

describe Bus do
  before :all do
    @server = Server.new
    wait
  end

  after :all do
    @server.quit
    wait
  end

  describe 'instance' do
    before :all do
      @audio    = AudioBus.allocate @server, channels: 4
      @control  = ControlBus.allocate @server, channels: 4
    end

    describe AudioBus do
      it 'should allocate consecutive when passing more than one channel for audio' do
        @audio.rate.should == :audio
        @audio.index.should == 16
        buses = @server.audio_buses
        buses[16..-1].count.should eq 4
        AudioBus.allocate(@server).index.should == 20
      end

      it 'should allocate consecutive when passing more than one channel for control' do
        @control.rate.should == :control
        @control.index.should == 0
        @server.control_buses.count.should eq 4
        ControlBus.allocate(@server).index.should == 4
      end

      it 'should set the number of channels' do
        @audio.channels.should   == 4
        @control.channels.should == 4
      end

      it 'should depend on a main bus' do
        @server.audio_buses[16].main_bus.should  == @audio   #main bus
        @server.audio_buses[17].main_bus.should  == @audio   #main bus
        @server.control_buses[0].main_bus.should == @control #main bus
        @server.control_buses[1].main_bus.should == @control #main bus
      end
    end
  end

  describe 'messaging' do
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

    before :all do
      @server.boot
      @server.send '/dumpOSC', 3
      wait
    end

    describe ControlBus do
      before do
        @bus = ControlBus.allocate @server
        @rate = :control
      end

      it { @bus.to_map.should == 'c0' }
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
end
