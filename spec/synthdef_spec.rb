require_relative 'helper'

require 'scruby/core_ext/typed_array'
require 'scruby/core_ext/delegator_array'

require 'scruby/control_name'
require 'scruby/env'

require 'scruby/ugens/ugen'
require 'scruby/ugens/ugen_operations'
require 'scruby/ugens/operation_ugens'
require 'scruby/ugens/multi_out'
require 'scruby/ugens/ugens'

require 'scruby/synthdef'

include Scruby
include Ugens

describe SynthDef, 'instantiation' do

  describe 'initialize' do
    before do
      @sdef = SynthDef.new(:name) {}
      @sdef.stub :collect_control_names
    end

    it 'should instantiate' do
      @sdef.should_not be_nil
      @sdef.should be_instance_of(SynthDef)
    end

    it 'should protect attributes' do
      @sdef.should_not respond_to(:name=)
      @sdef.should_not respond_to(:children=)
      @sdef.should_not respond_to(:constants=)
      @sdef.should_not respond_to(:control_names=)

      @sdef.should respond_to(:name)
      @sdef.should respond_to(:children)
      @sdef.should respond_to(:constants)
      @sdef.should respond_to(:control_names)
    end

    it 'should accept name and set it as an attribute as string' do
      @sdef.name.should == 'name'
    end

    it 'should initialize with an empty array for children' do
      @sdef.children.should == []
    end
  end

  describe 'options' do
    before do
      @options = double Hash
    end

    it 'should accept options' do
      sdef = SynthDef.new(:hola, values: []) {}
    end

    it 'should use options' do
      sdef = SynthDef.new(:hola, values: nil, rates: nil) {}
    end

    it 'should set default values if not provided'
    it 'should accept a graph function'
  end

  describe '#collect_control_names' do
    before do
      @sdef     = SynthDef.new(:name) {}
      @function = double 'grap_function', arguments: [:arg1, :arg2, :arg3]
    end

    it 'should get the argument names for the provided function' do
      @function.should_receive(:arguments).and_return []
      @sdef.send_msg :collect_control_names, @function, [], []
    end

    it 'should return empty array if the names are empty' do
      @function.should_receive(:arguments).and_return []
      @sdef.send_msg(:collect_control_names, @function, [], []).should == []
    end

    it 'should not return empty array if the names are not empty' do
      @sdef.send_msg(:collect_control_names, @function, [], []).should_not == []
    end

    it 'should instantiate and return a ControlName for each function name' do
      c_name = double :control_name
      ControlName.should_receive(:new).at_most(3).times.and_return c_name
      control_names = @sdef.send_msg :collect_control_names, @function, [1,2,3], []
      control_names.size.should == 3
      control_names.collect { |e| e.should == c_name }
    end

    it 'should pass the argument value, the argument index and the rate(if provided) to the ControlName at instantiation' do
      cns = @sdef.send_msg :collect_control_names, @function, [1, 2, 3], []
      cns.should == [1.0, 2.0, 3.0].map { |val| ControlName.new("arg#{ val.to_i }", val, :control, val.to_i - 1) }
      cns = @sdef.send_msg :collect_control_names, @function, [1, 2, 3], [:ir, :tr, :ir]
      cns.should == [[1.0, :ir], [2.0, :tr], [3.0, :ir]].map { |val, rate| ControlName.new("arg#{ val.to_i }", val, rate, val.to_i - 1)}
    end

    it 'should not return more elements than the function argument number' do
      @sdef.send_msg(:collect_control_names, @function, [1, 2, 3, 4, 5], []).length.should eq 3
    end
  end

  describe '#build_controls' do
    before do
      @sdef     = SynthDef.new(:name) {}
      @function = double 'grap_function', arguments: [:arg1, :arg2, :arg3, :arg4]
      @control_names = Array.new(rand(10)+15) { |i| ControlName.new "arg#{i+1}".to_sym, i, [:scalar, :trigger, :control][rand(3)], i }
    end

    it 'should call Control#and_proxies..' do
        rates = @control_names.collect { |c| c.rate }.uniq
        Control.should_receive(:and_proxies_from).exactly(rates.size).times
        @sdef.send_msg :build_controls, @control_names
    end

    it 'should call Control#and_proxies.. with args' do
      Control.should_receive(:and_proxies_from).with(@control_names.select { |c| c.rate == :scalar  }) unless @control_names.select { |c| c.rate == :scalar  }.empty?
      Control.should_receive(:and_proxies_from).with(@control_names.select { |c| c.rate == :trigger }) unless @control_names.select { |c| c.rate == :trigger }.empty?
      Control.should_receive(:and_proxies_from).with(@control_names.select { |c| c.rate == :control }) unless @control_names.select { |c| c.rate == :control }.empty?
      @sdef.send_msg(:build_controls, @control_names)
    end

    it do
      @sdef.send_msg(:build_controls, @control_names).should be_instance_of(Array)
    end

    it 'should return an array of OutputProxies' do
      @sdef.send_msg(:build_controls, @control_names).each { |e| e.should be_instance_of(OutputProxy) }
    end

    it 'should return an array of OutputProxies sorted by ControlNameIndex' do
      @sdef.send_msg(:build_controls, @control_names).collect { |p| p.control_name.index }.should == (0...@control_names.size).to_a
    end

    it 'should call graph function with correct args' do
      function = double('function', call: [])
      proxies  = @sdef.send_msg(:build_controls, @control_names)
      @sdef.stub(:build_controls).and_return(proxies)
      function.should_receive(:call).with(*proxies)
      @sdef.send_msg(:build_ugen_graph, function, @control_names)
    end

    it 'should set @sdef' do
      function = lambda {}
      Ugen.should_receive(:synthdef=).with(@sdef)
      Ugen.should_receive(:synthdef=).with(nil)
      @sdef.send_msg(:build_ugen_graph, function, [])
    end

    it 'should collect constants for simple children array' do
      children = [MockUgen.new(:audio, 100), MockUgen.new(:audio, 200), MockUgen.new(:audio, 100, 300)]
      @sdef.send_msg(:collect_constants, children).should == [100.0, 200.0, 300.0]
    end

    it 'should collect constants for children arrays' do
      children = [MockUgen.new(:audio, 100), [MockUgen.new(:audio, 400), [MockUgen.new(:audio, 200), MockUgen.new(:audio, 100, 300)]]]
      @sdef.send_msg(:collect_constants, children).should == [100.0, 400.0, 200.0, 300.0]
    end

    it 'should remove nil from constants array'
  end
end

describe 'encoding' do

  before do
    @sdef = SynthDef.new(:hola) { SinOsc.ar }
    @encoded = [ 83, 67, 103, 102, 0, 0, 0, 1, 0, 1, 4, 104, 111, 108, 97, 0, 2, 67, -36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 6, 83, 105, 110, 79, 115, 99, 2, 0, 2, 0, 1, 0, 0, -1, -1, 0, 0, -1, -1, 0, 1, 2, 0, 0 ].pack('C*')
  end

  it 'should get values' do
    @sdef.values
  end

  it 'should encode init stream' do
    @sdef.encode[0..9].should == @encoded[0..9]
  end

  it 'should encode is, name' do
    @sdef.encode[0..14].should == @encoded[0..14]
  end

  it 'should encode is, name, constants' do
    @sdef.encode[0..24].should == @encoded[0..24]
  end

  it 'should encode is, name, consts, values' do
    @sdef.encode[0..26].should == @encoded[0..26]
  end

  it 'should encode is, name, consts, values, controls' do
    @sdef.encode[0..28].should == @encoded[0..28]
  end

  it 'should encode is, name, consts, values, controls, children' do
    @sdef.encode[0..53].should == @encoded[0..53]
  end

  it 'should encode is, name, consts, values, controls, children, variants stub' do
    @sdef.encode.should == @encoded
  end

  describe 'sending' do
    it 'should accept an array or several Servers'
    it 'should not accept non servers'
    it 'should send self to each of the servers'
    it 'should send to Server.all if not provided with a list of servers'
  end
end
