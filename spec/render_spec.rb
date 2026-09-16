require_relative 'helper'

require 'scruby'

include Scruby

describe Synth do

  before :all do
    Server.clear

    @server = Server.new log: true, dump: true
    @server.boot
    @server.send '/dumpOSC', 3

    wait
  end

  after :all do
    @server.quit
    wait
  end

  describe 'play a sound' do

    before do
      @server.log.clear
    end

    it 'play a sin sound' do
      sdef  = SynthDef.new :sin, values: [456, 0.34] do |freq, amp|
        sig  = SinOsc.ar(freq, mul: amp, doneAction: 2)
        Out.ar(0, sig)
      end
      sdef.send
      sleep 0.05
      test = Synth.new :sin, freq: 150, amp: 0.25

      sleep 3

      test.free

      wait
    end

    it 'play two sin sounds with soft crossover' do

      group = Group.new

      sdef  = SynthDef.new :sin, values: [456, 0.34] do |freq, amp|
        sig  = SinOsc.ar(freq, mul: amp, doneAction: 2)
        Out.ar(0, sig)
      end
      sdef.send
      sleep 0.05
      test = Synth.new :sin, freq: 220, amp: 0.26
      puts "test = #{test}"

      sleep 3

      test.set(fadeTime: 0.5, gate: 0)
      wait

      test = Synth.tail test.group, :sin, freq: 225, amp: 0.27, fadeTime: 0.5, out: 4, i_out: 4
      puts "test = #{test}"

      sleep 3

      test.free

      wait
    end

    it 'play a simple sound' do
      sdef  = SynthDef.new :melo, :values => [456, 0.34, 0.45] do |freq, amp, a, b, c|
        gate = EnvGen.kr( Env.perc(0, 0.2) )
        sig  = SinOsc.ar( [freq, freq * 1.01], mul: SinOsc.kr(40) * amp * 0.7, add: SinOsc.kr(0.5, :mul => 2.5) ) * EnvGen.kr( Env.asr(2, 1, 3), gate: gate, doneAction: 2 )
        sig  = SinOsc.ar( [freq, freq * 1.01], mul: SinOsc.kr(8) * amp * 0.3, add: SinOsc.kr(0.5, :mul => 2.5) ) * EnvGen.kr( Env.asr(2, 1, 2), gate: gate ) + sig
        sig  = SinOsc.ar( [freq * 0.25, freq * 0.251], mul: SinOsc.kr(30) * amp * 0.3 ) * EnvGen.kr( Env.asr(2, 1, 3), gate: gate ) + sig
        sig  = SinOsc.ar( freq * 2, mul: SinOsc.kr(500, mul: 0.1) * amp * 0.1 ) * EnvGen.kr( Env.asr(0, 1, 2), gate: gate ) + sig
        sig  = SinOsc.ar( freq * 0.25, mul: amp * 0.2 ) * EnvGen.kr( Env.asr(0, 1, 0.4), gate: gate ) + sig
        res  = Resonz.ar( sig, EnvGen.kr( Env.asr(0.5, 3,c * 2) )* a * 10000 )

        Out.ar( 0, [res[0] * 6 + sig[1] * 0.8] * 2 )
      end
      sdef.send
      sleep 0.05
      test = Synth.new :melo, freq: 220, amp: 0.5

      sleep 3

      test.free

      wait
    end


  end
end
