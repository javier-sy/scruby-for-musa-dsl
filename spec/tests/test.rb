# TODO
# - Remove arguments dependency, support for < 1.9.2
# - Clean up monkeypatches (esp String#encode)
# - Replace OSC / fix hanging
# - Fix specs
# - Add instructions (e.g. scsyth location)
require 'scruby'
require 'pry'

s = Server.new
s.boot

begin
  d = SynthDef.new :fm do |freq, amp, dur|
    mod_env = EnvGen.kr Env.new( d(600, 200, 100), d(0.7,0.3) ), 1, :timeScale => dur
    mod     = SinOsc.ar freq * 1.4, :mul => mod_env
    sig     = SinOsc.ar freq + mod
    env     = EnvGen.kr Env.new( d(0, 1, 0.6, 0.2, 0.1, 0), d(0.001, 0.005, 0.3, 0.5, 0.7) ), 1, :timeScale => dur, :doneAction => 2
    sig     = sig * amp * env
    Out.ar  0, [sig, sig]
  end
  d.send

  sleep 1

  Synth.new :fm, :freq => 220, :amp => 0.4, :dur => 1
rescue => e
  puts "Uncaugt error: #{e}"
  puts e.backtrace
end

sleep 1
s.quit
