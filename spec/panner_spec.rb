require_relative 'helper'

require 'scruby/core_ext/delegator_array'
require 'scruby/control_name'
require 'scruby/env'
require 'scruby/ugens/ugen'
require 'scruby/ugens/ugen_operations'
require 'scruby/ugens/multi_out'
require 'scruby/ugens/ugens'
require 'scruby/ugens/panner'

include Scruby
include Ugens

describe 'Panner' do
  shared_examples_for 'Panner' do
    before do
      @pan      = @class.send @method, *@params, **@named_params
      @instance = @pan.first.source
    end

    it 'should output a DelegatorArray' do
      @pan.should be_a(DelegatorArray)
    end

    it 'should have correct rate' do
      @instance.rate.should == @rate
    end

    it 'should return an array of output proxies' do
      @pan.should be_a(Array)
      @pan.length.should eq @channels
      @pan.each_with_index do |proxy, i|
        proxy.source.should be_a(@class)
        proxy.should be_a(OutputProxy)
        proxy.output_index.should == i
      end
    end

    it 'should accept control rate inputs unless rate is audio'
  end

  shared_examples_for 'Panner with control rate' do
    before do
      @method = :kr
      @rate   = :control
    end
    it_should_behave_like 'Panner'
  end

  shared_examples_for 'Panner with audio rate' do
    before do
      @method = :ar
      @rate   = :audio
    end
    it_should_behave_like 'Panner'

    it 'should just accept audio inputs if rate is audio' # do
     #      lambda { @class.new( :audio, MockUgen.new(:control) ) }.should raise_error(ArgumentError)
     #    end
  end

  shared_examples_for 'Panner with array as input' do
    it 'should have n channels' do
      @arrayed.length.should eq @ugens.size
    end

    it 'should have array as channel' do
      @arrayed.each { |a| a.length.should eq @channels }
    end

    it 'should have the same source class' do
      @arrayed.flatten.source.uniq.length.should eq @ugens.size
    end
  end

  shared_examples_for 'Multi input panner' do
    describe 'two ugens as input' do
      before do
        @params[0] = @ugens = [@ugen] * 2
        @arrayed   = @class.ar *@params, **@named_params
      end
      it_should_behave_like 'Panner with array as input'
    end

    describe 'four ugens as input' do
      before do
        @params[0] = @ugens = [@ugen] * 4
        @arrayed   = @class.ar *@params, **@named_params
        # p @arrayed.first.first.source.output_specs
      end
      it_should_behave_like 'Panner with array as input'
    end
  end

  describe Pan2 do
    before do
      @class    = Pan2
      @ugen     = MockUgen.new :audio, 1, 2
      @params   = [@ugen]
      @named_params = { pos: 0.5, level: 1.0 }
      @channels = 2
    end
    it_should_behave_like 'Panner with audio rate'
    it_should_behave_like 'Panner with control rate'
    it_should_behave_like 'Multi input panner'
  end

  describe LinPan2 do
    before do
      @class    = LinPan2
      @ugen     = MockUgen.new :audio, 1, 2
      @params   = [@ugen]
      @named_params = { pos: 0.5, level: 1.0 }
      @channels = 2
    end
    it_should_behave_like 'Panner with audio rate'
    it_should_behave_like 'Panner with control rate'
    it_should_behave_like 'Multi input panner'
  end

  describe Pan4 do
    before do
      @class    = Pan4
      @ugen     = MockUgen.new :audio, 1, 2
      @params   = [@ugen]
      @named_params = { xpos: 0.5, ypos: 0.5, level: 1.0 }
      @channels = 4
    end
    it_should_behave_like 'Panner with audio rate'
    it_should_behave_like 'Panner with control rate'
    it_should_behave_like 'Multi input panner'
  end

  describe Balance2 do
    before do
      @class    = Balance2
      @ugen     = MockUgen.new :audio, 1, 2
      @ugen2    = MockUgen.new :audio, 2, 4
      @params   = [@ugen, @ugen2]
      @named_params = { pos: 0.5, level: 1.0 }
      @channels = 2
    end
    it_should_behave_like 'Panner with audio rate'
    it_should_behave_like 'Panner with control rate'
    it_should_behave_like 'Multi input panner'
  end

  describe Rotate2 do
    before do
      @class    = Rotate2
      @ugen     = MockUgen.new :audio, 1, 2
      @ugen2    = MockUgen.new :audio, 2, 4
      @params   = [@ugen, @ugen2]
      @named_params = { pos: 0.5 }
      @channels = 2
    end
    it_should_behave_like 'Panner with audio rate'
    it_should_behave_like 'Panner with control rate'
    it_should_behave_like 'Multi input panner'
  end

  describe PanB do
    before do
      @class    = PanB
      @ugen     = MockUgen.new :audio, 1, 2
      @params   = [@ugen]
      @named_params = { azimuth: 0.5, elevation: 0.5, gain: 1.0 }
      @channels = 4
    end
    it_should_behave_like 'Panner with audio rate'
    it_should_behave_like 'Panner with control rate'
    it_should_behave_like 'Multi input panner'
  end

  describe PanB2 do
    before do
      @class    = PanB2
      @ugen     = MockUgen.new :audio, 1, 2
      @params   = [@ugen]
      @named_params = { azimuth: 0.5, gain: 1.0 }
      @channels = 3
    end
    it_should_behave_like 'Panner with audio rate'
    it_should_behave_like 'Panner with control rate'
    it_should_behave_like 'Multi input panner'
  end

  describe BiPanB2 do
    before do
      @class    = BiPanB2
      @ugen2    = MockUgen.new(:audio, 2, 4)
      @ugen     = MockUgen.new(:audio, 1, 2)
      @params   = [@ugen, @ugen2]
      @named_params = { azimuth: 0.5, gain: 0.5 }
      @channels = 3
    end
    it_should_behave_like 'Panner with audio rate'
    it_should_behave_like 'Panner with control rate'
    it_should_behave_like 'Multi input panner'
  end

  describe DecodeB2, 'five channels' do
    before do
      @class    = DecodeB2
      @params   = [5, 0.5, 0.5, 0.5]
      @named_params = { orientation: 0.5 }
      @channels = 5
    end
    it_should_behave_like 'Panner with audio rate'
    it_should_behave_like 'Panner with control rate'
  end

  describe DecodeB2, 'seven channels' do
    before do
      @class    = DecodeB2
      @params   = 7, 0.5, 0.5, 0.5
      @named_params = { orientation: 0.5 }
      @channels = 7
    end
    it_should_behave_like 'Panner with audio rate'
    it_should_behave_like 'Panner with control rate'
  end

  describe PanAz, 'five channels' do
    before do
      @class    = PanAz
      @ugen     = MockUgen.new(:audio, 1, 2)
      @params   = [5, @ugen]
      @named_params = { pos: 0.5, level: 0.5, width: 0.5, orientation: 0.5 }
      @channels = 5
    end
    it_should_behave_like 'Panner with audio rate'
    it_should_behave_like 'Panner with control rate'
  end
end
